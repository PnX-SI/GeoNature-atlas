-- +-----------------------------------------------------------------------------------------------+
-- Taxons les plus observés sur la période en cours.
-- Par défaut -15 jours +15 jours toutes années confondues.
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
    WHERE date_part('day', obs.dateobs) >= date_part('day', 'now'::date - :taxon_time)
        AND date_part('month', obs.dateobs) = date_part('month', 'now'::date - :taxon_time)
        OR date_part('day', obs.dateobs) <= date_part('day', 'now'::date + :taxon_time)
        AND date_part('month', obs.dateobs) = date_part('day', 'now'::date + :taxon_time)
    GROUP BY obs.cd_ref, tax.lb_nom, tax.group2_inpn, tax.nom_vern, m.id_media, m.url, m.chemin, m.id_type
    ORDER BY (count(*)) DESC
    LIMIT 12
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_taxons_plus_observes
    USING btree (cd_ref);


