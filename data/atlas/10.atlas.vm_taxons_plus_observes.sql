-- 12 taxons les plus observés sur la période en cours (par défaut -15 jours +15 jours toutes années confondues)

CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS
    SELECT
        count(*) AS nb_obs,
        obs.cd_ref,
        tax.lb_nom,
        tax.group2_inpn,
        tax.nom_vern,
        m.id_media,
        m.url,
        m.chemin,
        m.id_type
    FROM atlas.vm_observations AS obs
        JOIN atlas.vm_taxons AS tax
            ON tax.cd_ref = obs.cd_ref
        LEFT JOIN atlas.vm_medias AS m
            ON (m.cd_ref = obs.cd_ref AND m.id_type = 1)
    WHERE date_part('day'::text, obs.dateobs) >= date_part('day'::text, 'now'::text::date - 15)
        AND date_part('month'::text, obs.dateobs) = date_part('month'::text, 'now'::text::date - 15)
        OR date_part('day'::text, obs.dateobs) <= date_part('day'::text, 'now'::text::date + 15)
        AND date_part('month'::text, obs.dateobs) = date_part('day'::text, 'now'::text::date + 15)
    GROUP BY obs.cd_ref, tax.lb_nom, tax.group2_inpn, tax.nom_vern, m.id_media, m.url, m.chemin, m.id_type
    ORDER BY (count(*)) DESC
    LIMIT 12;

CREATE UNIQUE INDEX ON atlas.vm_taxons_plus_observes
    USING btree (cd_ref);


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
