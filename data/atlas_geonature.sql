-- Création des foreign data wrappers pour se connecter à la base mère de GeoNature

--SYNTHESE
CREATE FOREIGN TABLE synthese.syntheseff
(
  id_synthese serial NOT NULL,
  id_source integer,
  id_fiche_source character varying(50),
  code_fiche_source character varying(50),
  id_organisme integer,
  id_protocole integer,
  id_precision integer,
  cd_nom integer,
  insee character(5),
  dateobs date NOT NULL,
  observateurs character varying(255),
  determinateur character varying(255),
  altitude_retenue integer,
  remarques text,
  date_insert timestamp without time zone,
  date_update timestamp without time zone,
  derniere_action character(1),
  supprime boolean,
  the_geom_point geometry('POINT',3857),
  id_lot integer,
  id_critere_synthese integer,
  the_geom_3857 geometry,
  effectif_total integer,
  the_geom_2154 geometry
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'syntheseff');
ALTER TABLE synthese.syntheseff OWNER TO myuser;
GRANT ALL ON TABLE synthese.syntheseff TO myuser;

--TAXONOMIE

CREATE FOREIGN TABLE taxonomie.taxref
(
  cd_nom integer NOT NULL,
  id_statut character(1),
  id_habitat integer,
  id_rang character(4),
  regne character varying(20),
  phylum character varying(50),
  classe character varying(50),
  ordre character varying(50),
  famille character varying(50),
  cd_taxsup integer,
  cd_ref integer,
  lb_nom character varying(100),
  lb_auteur character varying(250),
  nom_complet character varying(255),
  nom_valide character varying(255),
  nom_vern character varying(1000),
  nom_vern_eng character varying(500),
  group1_inpn character varying(50),
  group2_inpn character varying(50),
  nom_complet_html character varying(500),
  cd_sup integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'taxref');
ALTER TABLE taxonomie.taxref OWNER TO myuser;
GRANT ALL ON TABLE taxonomie.taxref TO myuser;


CREATE FOREIGN TABLE taxonomie.cor_taxon_attribut
(
  id_attribut integer NOT NULL,
  valeur_attribut text NOT NULL,
  cd_ref integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'cor_taxon_attribut');
ALTER TABLE taxonomie.cor_taxon_attribut OWNER TO myuser;
GRANT ALL ON TABLE taxonomie.cor_taxon_attribut TO myuser;



CREATE FOREIGN TABLE taxonomie.t_medias
(
  id_media serial NOT NULL,
  cd_ref integer,
  titre character(255) NOT NULL,
  url character(255),
  chemin character(255),
  auteur character(100),
  desc_media text,
  date_media date,
  id_type integer NOT NULL
)
 SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 't_medias');
ALTER TABLE taxonomie.t_medias OWNER TO myuser;
GRANT ALL ON TABLE taxonomie.t_medias TO myuser;



