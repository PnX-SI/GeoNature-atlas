-- +-----------------------------------------------------------------------------------------------+
-- Taxa most viewed on a selected period for each day of year.
-- Used a leap year (2024) to take into account 29th February => 366 days.
-- By default, -15 days +15 days for each day of year for all years in database.
CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS
    WITH period_dates AS (
        SELECT
            generate_series(1, ceiling(366 * 1.0 / (2 * :taxon_time)), 1) AS id_period,
            generate_series(
                '2024-01-01 00:00'::timestamp,
                '2024-12-31 23:59'::timestamp,
                CONCAT(2 * :taxon_time, ' day')::interval
            )::date AS period_date
    ),
    perpetual_calendar AS (
        SELECT
            id_period,
            date_part('day', p.period_date) AS day_start,
            date_part('month', p.period_date) AS month_start,
            date_part('day', p.period_date + (2 * :taxon_time)) AS day_end,
            date_part('month', p.period_date + (2 * :taxon_time)) AS month_end
        FROM period_dates
    )
    SELECT
        pc.id_period,
        pc.day_start,
        pc.month_start,
        pc.day_end,
        pc.month_end,
        c.cd_ref,
        t.lb_nom,
        t.group2_inpn,
        t.nom_vern,
        m.id_media,
        m.url,
        m.chemin,
        m.id_type,
        c.nb_obs
    FROM perpetual_calendar AS pc
        JOIN LATERAL (
            (
                SELECT
                    o.cd_ref,
                    count(*) AS nb_obs
                FROM atlas.vm_observations AS o
                    JOIN atlas.vm_taxons AS t
                        ON t.cd_ref = o.cd_ref
                WHERE (
                        (date_part('day', o.dateobs) >= pc.day_start
                        AND date_part('month', o.dateobs) = pc.month_start)
                        OR
                        (date_part('day', o.dateobs) < pc.day_end
                        AND date_part('month', o.dateobs) = pc.month_end)
                    )
                    AND t.regne = 'Animalia'
                GROUP BY o.cd_ref
                ORDER BY "nb_obs" DESC
                LIMIT 12
            )
            UNION
            (
                SELECT
                    o.cd_ref,
                    count(*) AS nb_obs
                FROM atlas.vm_observations AS o
                    JOIN atlas.vm_taxons AS t
                        ON t.cd_ref = o.cd_ref
                WHERE (
                        (date_part('day', o.dateobs) >= pc.day_start
                        AND date_part('month', o.dateobs) = pc.month_start)
                        OR
                        (date_part('day', o.dateobs) < pc.day_end
                        AND date_part('month', o.dateobs) = pc.month_end)
                    )
                    AND t.regne = 'Plantae'
                GROUP BY o.cd_ref
                ORDER BY "nb_obs" DESC
                LIMIT 12
            )
            UNION
            (
                SELECT
                    o.cd_ref,
                    count(*) AS nb_obs
                FROM atlas.vm_observations AS o
                    JOIN atlas.vm_taxons AS t
                        ON t.cd_ref = o.cd_ref
                WHERE (
                        (date_part('day', o.dateobs) >= pc.day_start
                        AND date_part('month', o.dateobs) = pc.month_start)
                        OR
                        (date_part('day', o.dateobs) < pc.day_end
                        AND date_part('month', o.dateobs) = pc.month_end)
                    )
                    AND t.regne NOT IN ('Animalia', 'Plantae')
                GROUP BY o.cd_ref
                ORDER BY "nb_obs" DESC
                LIMIT 12
            )
        ) AS c ON TRUE
        JOIN atlas.vm_taxons AS t
            ON t.cd_ref = c.cd_ref
        LEFT JOIN atlas.vm_medias AS m
            ON (m.cd_ref = c.cd_ref AND m.id_type = 1)
    ORDER BY id_period ASC, nb_obs DESC;

CREATE UNIQUE INDEX ON atlas.vm_taxons_plus_observes
    USING btree (id_period, cd_ref);


-- +-----------------------------------------------------------------------------------------------+
CREATE OR REPLACE FUNCTION atlas.find_all_taxons_childs(id integer)
  RETURNS SETOF integer
  LANGUAGE plpgsql IMMUTABLE
AS
$function$
    -- Fonction qui permet de lister tous les taxons enfants d'un taxon.
    -- Param : cd_nom ou cd_ref d'un taxon quelque soit son rang.
    -- Retourne le cd_nom de tous les taxons enfants sous forme d'un jeu de données
    -- utilisable comme une table.
    -- Usage : SELECT atlas.find_all_taxons_childs(197047);
    --    ou SELECT * FROM atlas.vm_taxons WHERE cd_ref IN(SELECT * FROM atlas.find_all_taxons_childs(197047))
    DECLARE
        inf RECORD;
        c integer;

    BEGIN
        SELECT INTO c count(*) FROM atlas.vm_taxref WHERE cd_taxsup = id;
        IF c > 0 THEN
            FOR inf IN (
                WITH RECURSIVE descendants AS (
                    SELECT tx1.cd_nom
                    FROM atlas.vm_taxref AS tx1
                    WHERE tx1.cd_taxsup = id

                    UNION ALL

                    SELECT tx2.cd_nom
                    FROM descendants AS d
                        JOIN atlas.vm_taxref AS tx2
                            ON tx2.cd_taxsup = d.cd_nom
                )
                SELECT cd_nom FROM descendants
            ) LOOP
                RETURN NEXT inf.cd_nom;
            END LOOP;
        END IF;
    END;
$function$;
