-- Création de la table fille en foreign data wrapper, connectée à la base mère de UsersHub (usershubdbserver)


CREATE FOREIGN TABLE synthese.bib_organismes
   ( id_organisme integer NOT NULL,
    nom_organisme character varying(100) NOT NULL,
    adresse_organisme character varying(128),
    cp_organisme character varying(5),
    ville_organisme character varying(100),
    tel_organisme character varying(14),
    fax_organisme character varying(14),
    email_organisme character varying(100)
    )
   SERVER usershubdbserver
   OPTIONS (schema_name 'utilisateurs', table_name 'bib_organismes');
ALTER TABLE synthese.bib_organismes OWNER TO myuser;
GRANT ALL ON TABLE synthese.bib_organismes TO myuser;
