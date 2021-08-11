-------- CRÉATION DU SCHÉMA -------------
CREATE SCHEMA utilisateurs;

-- TABLE bib_organism
CREATE FOREIGN TABLE utilisateurs.bib_organisms (
    id_organism int4 OPTIONS(column_name 'id_organisme') NOT NULL,
    uuid_organism uuid OPTIONS(column_name 'uuid_organisme') NULL,
    nom_organism varchar(500) OPTIONS(column_name 'nom_organisme') NULL,
    adresse_organism varchar(128) OPTIONS(column_name 'adresse_organisme') NULL,
    cp_organism varchar(5) OPTIONS(column_name 'cp_organisme') NULL,
    ville_organism varchar(50) OPTIONS(column_name 'ville_organisme') NULL,
    tel_organism varchar(14) OPTIONS(column_name 'tel_organisme') NULL,
    fax_organism varchar(14) OPTIONS(column_name 'fax_organisme') NULL,
    email_organism varchar(100) OPTIONS(column_name 'email_organisme') NULL,
    url_organism varchar(255) OPTIONS(column_name 'url_organisme') NULL,
    url_logo varchar(255) OPTIONS(column_name 'url_logo') NULL,
    id_parent int4 OPTIONS(column_name 'id_parent') NULL
)
SERVER geonaturedbserver
OPTIONS (schema_name 'utilisateurs', table_name 'bib_organismes');

-- TABLE cor_data_actor
CREATE FOREIGN TABLE utilisateurs.cor_dataset_actor (
    id_cda int4 OPTIONS(column_name 'id_cda') NOT NULL,
    id_dataset int4 OPTIONS(column_name 'id_dataset') NULL,
    id_role int4 OPTIONS(column_name 'id_role') NULL,
    id_organism int4 OPTIONS(column_name 'id_organism') NULL,
    id_nomenclature_actor_role int4 OPTIONS(column_name 'id_nomenclature_actor_role') NULL
)
SERVER geonaturedbserver
OPTIONS (schema_name 'gn_meta', table_name 'cor_dataset_actor');

--CRÉATION VUE MATÉRIALISÉE
CREATE MATERIALIZED VIEW atlas.vm_organisms
AS SELECT cd_ref, count(*) as nb_observations, bo.id_organism , nom_organism , adresse_organism , cp_organism , ville_organism , tel_organism , email_organism , url_organism ,url_logo
   FROM utilisateurs.bib_organisms bo
     JOIN utilisateurs.cor_dataset_actor cda ON bo.id_organism =cda.id_organism 
     JOIN synthese.synthese s ON s.id_dataset =cda.id_dataset 
     JOIN taxonomie.taxref t on s.cd_nom=t.cd_nom
  group by t.cd_ref, bo.id_organism, bo.nom_organism, bo.adresse_organism, bo.cp_organism, bo.ville_organism, bo.tel_organism, bo.email_organism, bo.url_organism, bo.url_logo
  with data;