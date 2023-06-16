-- Exclusion des médias supprimés
DROP MATERIALIZED VIEW atlas.vm_taxons_plus_observes;
DROP MATERIALIZED VIEW atlas.vm_medias;

CREATE MATERIALIZED VIEW atlas.vm_medias AS
SELECT t_medias.id_media,
    t_medias.cd_ref,
    t_medias.titre,
    t_medias.url,
    t_medias.chemin,
    t_medias.auteur,
    t_medias.desc_media,
    t_medias.date_media,
    t_medias.id_type,
    t_medias.licence,
    t_medias.source
   FROM taxonomie.t_medias
WHERE NOT t_medias.supprime = true;

CREATE UNIQUE INDEX ON atlas.vm_medias (id_media);


CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS
SELECT count(*) AS nb_obs,
    obs.cd_ref,
    tax.lb_nom,
    tax.group2_inpn,
    tax.nom_vern,
    m.id_media,
    m.url,
    m.chemin,
    m.id_type
   FROM atlas.vm_observations obs
     JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref
     LEFT JOIN atlas.vm_medias m ON m.cd_ref = obs.cd_ref AND m.id_type = 1
  WHERE date_part('day'::text, obs.dateobs) >= date_part('day'::text, 'now'::text::date - 15) AND date_part('month'::text, obs.dateobs) = date_part('month'::text, 'now'::text::date - 15) OR date_part('day'::text, obs.dateobs) <= date_part('day'::text, 'now'::text::date + 15) AND date_part('month'::text, obs.dateobs) = date_part('day'::text, 'now'::text::date + 15)
  GROUP BY obs.cd_ref, tax.lb_nom, tax.nom_vern, m.url, m.chemin, tax.group2_inpn, m.id_type, m.id_media
  ORDER BY (count(*)) DESC
 LIMIT 12
WITH DATA;

-- View indexes:
CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx ON atlas.vm_taxons_plus_observes USING btree (cd_ref);


---------------------------
DROP MATERIALIZED VIEW atlas.vm_cor_taxon_organism;

CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_organism AS
SELECT obs_by_dataset_and_orga.nb_obs AS nb_observations,
    obs_by_dataset_and_orga.cd_ref,
    bo.id_organisme AS id_organism,
    nom_organisme AS nom_organism,
    adresse_organisme AS adresse_organism,
    cp_organisme AS cp_organism,
    ville_organisme AS ville_organism,
    tel_organisme AS tel_organism,
    email_organisme AS email_organism,
    url_organisme AS url_organism,
    url_logo
FROM (
        SELECT
            COUNT(DISTINCT obs.id_observation) AS nb_obs,
            obs.cd_ref,
            rcda.id_organism
        FROM atlas.vm_observations AS obs
        JOIN gn_meta.cor_dataset_actor AS rcda
            ON obs.id_dataset = rcda.id_dataset
        GROUP BY
            obs.cd_ref,
            rcda.id_organism
) AS obs_by_dataset_and_orga
JOIN utilisateurs.bib_organismes AS bo
ON bo.id_organisme = obs_by_dataset_and_orga.id_organism;

CREATE UNIQUE INDEX vm_cor_taxon_organism_cd_ref_id_organism_idx
    ON atlas.vm_cor_taxon_organism USING btree (cd_ref, id_organism);

CREATE INDEX vm_cor_taxon_organism_id_organism_idx
    ON atlas.vm_cor_taxon_organism USING btree (id_organism);


DROP VIEW utilisateurs.reduced_cor_dataset_actor;




-- Rafraichissement des vues contenant les données de l'atlas
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data()
RETURNS VOID AS $$
BEGIN

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations_mailles;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_organism;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_mois;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_altitudes;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_attribut;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_search_taxon;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_medias;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons_plus_observes;

END
$$ LANGUAGE plpgsql;
