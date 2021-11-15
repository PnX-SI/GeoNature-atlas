--Réduction de la table utilisateurs.cor_dataset_actor pour sélectionner tous les organismes pour chaque jeu de données 
CREATE VIEW utilisateurs.reduced_cor_dataset_actor 
AS SELECT DISTINCT id_dataset, id_organism 
    FROM gn_meta.cor_dataset_actor;

--CRÉATION VUE MATÉRIALISÉE
    CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_organism AS
    select sum(obs_by_dataset_and_orga.nb_obs) as nb_observations, 
    obs_by_dataset_and_orga.cd_ref,
                        bo.id_organisme as id_organism,
                    nom_organisme as nom_organism, 
                    adresse_organisme as adresse_organism, 
                    cp_organisme as cp_organism, 
                    ville_organisme as ville_organism, 
                    tel_organisme as tel_organism, 
                    email_organisme as email_organism, 
                    url_organisme as url_organism,
                    url_logo
    from (
    select rcda.id_dataset, count(obs.id_observation) as nb_obs, obs.cd_ref, rcda.id_organism 
    from atlas.vm_observations obs
    join utilisateurs.reduced_cor_dataset_actor rcda on obs.id_dataset = rcda.id_dataset 
    group by rcda.id_dataset, obs.cd_ref, rcda.id_organism 
   	) AS obs_by_dataset_and_orga
   	join utilisateurs.bib_organismes bo on bo.id_organisme = obs_by_dataset_and_orga.id_organism
    group by obs_by_dataset_and_orga.cd_ref, bo.id_organisme, bo.nom_organisme, bo.adresse_organisme, bo.cp_organisme, bo.ville_organisme, 
    bo.tel_organisme, bo.email_organisme, bo.url_organisme, bo.url_logo;