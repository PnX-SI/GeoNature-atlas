-- +-----------------------------------------------------------------------------------------------+
-- Taxa most viewed on a selected period for each day of year.
-- Used a leap year (2024) to take into account 29th February => 366 days.
-- By default, -15 days +15 days for each day of year for all years in database.
CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS
    WITH days AS (
        SELECT
            date_part(
                'doy',
                generate_series(
                    '2024-01-01 00:00'::timestamp,
                    '2024-12-31 23:59'::timestamp,
                    '1 day'::interval
                )
            ) AS day_of_year,
            generate_series(
                '2024-01-01 00:00'::timestamp,
                '2024-12-31 23:59'::timestamp,
                '1 day'::interval
            )::date AS day
    )
    SELECT
        d.day_of_year,
        c.cd_ref,
        t.lb_nom,
        t.group2_inpn,
        t.nom_vern,
        m.id_media,
        m.url,
        m.chemin,
        m.id_type,
        c.nb_obs
    FROM days AS d
        JOIN LATERAL (
            SELECT
                o.cd_ref,
                count(*) AS nb_obs
            FROM atlas.vm_observations AS o
            WHERE (
                date_part('day', o.dateobs) >= date_part('day', d.day - :taxon_time)
                AND date_part('month', o.dateobs) = date_part('month', d.day - :taxon_time)
                OR
                date_part('day', o.dateobs) <= date_part('day', d.day + :taxon_time)
                AND date_part('month', o.dateobs) = date_part('day', d.day + :taxon_time)
            )
            GROUP BY o.cd_ref
            ORDER BY "nb_obs" DESC
            LIMIT 12
        ) AS c ON TRUE
        JOIN atlas.vm_taxons AS t
            ON t.cd_ref = c.cd_ref
        LEFT JOIN atlas.vm_medias AS m
            ON (m.cd_ref = c.cd_ref AND m.id_type = 1) ;

CREATE UNIQUE INDEX ON atlas.vm_taxons_plus_observes
    USING btree (day_of_year, cd_ref);

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
