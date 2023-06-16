 -- Vue Nombre d'oservation par taxons et par organisme

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