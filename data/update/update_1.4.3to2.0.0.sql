-- Schéma utilisateurs necessaire pour ajouter la dimension organisme à l'atlas

IMPORT FOREIGN SCHEMA utilisateurs
LIMIT TO (utilisateurs.bib_organismes)
FROM SERVER geonaturedbserver INTO utilisateurs;

GRANT SELECT ON TABLE utilisateurs.bib_organismes TO my_reader_user;

IMPORT FOREIGN SCHEMA gn_meta
LIMIT TO (gn_meta.cor_dataset_actor)
FROM SERVER geonaturedbserver INTO gn_meta;

GRANT SELECT ON TABLE gn_meta.cor_dataset_actor TO my_reader_user;

--Réduction de la table utilisateurs.cor_dataset_actor pour sélectionner tous les organismes pour chaque jeu de données
CREATE VIEW utilisateurs.reduced_cor_dataset_actor 
AS SELECT DISTINCT id_dataset, id_organism 
    FROM gn_meta.cor_dataset_actor;

GRANT SELECT ON TABLE utilisateurs.reduced_cor_dataset_actor TO my_reader_user;

--CRÉATION VUE MATÉRIALISÉE
CREATE MATERIALIZED VIEW atlas.vm_organisms
AS SELECT DISTINCT  cd_ref, 
                    count(*) as nb_observations, 
                    bo.id_organisme as id_organism,
                    nom_organisme as nom_organism, 
                    adresse_organisme as adresse_organism, 
                    cp_organisme as cp_organism, 
                    ville_organisme as ville_organism, 
                    tel_organisme as tel_organism, 
                    email_organisme as email_organism, 
                    url_organisme as url_organism,
                    url_logo
    FROM utilisateurs.bib_organismes bo
        JOIN utilisateurs.reduced_cor_dataset_actor cda ON bo.id_organisme=cda.id_organism
        JOIN synthese.synthese s ON s.id_dataset =cda.id_dataset 
        JOIN taxonomie.taxref t on s.cd_nom=t.cd_nom
    group by t.cd_ref, bo.id_organisme, bo.nom_organisme, bo.adresse_organisme, bo.cp_organisme, bo.ville_organisme, bo.tel_organisme, bo.email_organisme, bo.url_organisme, bo.url_logo
    with data; 

GRANT SELECT ON TABLE atlas.vm_organisms TO my_reader_user;
