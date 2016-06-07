
CREATE SCHEMA synthese AUTHORIZATION geonatatlas;
CREATE SCHEMA taxonomie AUTHORIZATION geonatatlas;
CREATE SCHEMA utilisateurs AUTHORIZATION geonatatlas;

CREATE FOREIGN TABLE utilisateurs.bib_organismes
(
  nom_organisme character varying(100) NOT NULL,
  adresse_organisme character varying(128),
  cp_organisme character varying(5),
  ville_organisme character varying(100),
  tel_organisme character varying(14),
  fax_organisme character varying(14),
  email_organisme character varying(100),
  id_organisme integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (table_name 'utilisateurs.bib_organismes');
ALTER TABLE utilisateurs.bib_organismes OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.bib_organismes TO geonatatlas;