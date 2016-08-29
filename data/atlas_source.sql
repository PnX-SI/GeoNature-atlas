-- object: taxonomie.t_medias | type: TABLE
CREATE TABLE IF NOT EXISTS taxonomie.t_medias(
    id_media serial NOT NULL,
    cd_ref integer,
    titre character varying(255) NOT NULL,
    url character varying(255),
    chemin character varying(255),
    auteur character varying(100),
    desc_media text,
    date_media date,
    is_public boolean NOT NULL DEFAULT true,
    supprime boolean NOT NULL DEFAULT false,
    id_type integer NOT NULL,
    CONSTRAINT id_media PRIMARY KEY (id_media),
    CONSTRAINT check_cd_ref_is_ref CHECK(cd_ref = taxonomie.find_cdref(cd_ref)),
    CONSTRAINT is_unique_titre UNIQUE (titre)
);
ALTER TABLE taxonomie.t_medias OWNER TO geonatuser;

-- object: taxonomie.bib_types_media | type: TABLE
CREATE TABLE IF NOT EXISTS taxonomie.bib_types_media(
    id_type integer NOT NULL,
    nom_type_media character varying(100) NOT NULL,
    desc_type_media text,
    CONSTRAINT id PRIMARY KEY (id_type)
);
ALTER TABLE taxonomie.bib_types_media OWNER TO geonatuser;

CREATE OR REPLACE FUNCTION taxonomie.insert_t_medias()
  RETURNS trigger AS
$BODY$
DECLARE
	trimtitre text;
BEGIN
	new.date_media = now();
	trimtitre = replace(new.titre, ' ', '');
	new.url = new.chemin || new.cd_ref || '_' || trimtitre || '.jpg';
	RETURN NEW; 			
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxonomie.insert_t_medias() OWNER TO cartopne;
GRANT EXECUTE ON FUNCTION taxonomie.insert_t_medias() TO public;

--DROP TRIGGER tri_insert_t_medias ON taxonomie.t_medias;
CREATE TRIGGER tri_insert_t_medias
  BEFORE INSERT
  ON taxonomie.t_medias
  FOR EACH ROW
  EXECUTE PROCEDURE taxonomie.insert_t_medias();

-- object: fk_t_media_bib_noms | type: CONSTRAINT
ALTER TABLE taxonomie.t_medias DROP CONSTRAINT IF EXISTS fk_t_media_bib_noms CASCADE;
ALTER TABLE taxonomie.t_medias ADD CONSTRAINT fk_t_media_bib_noms FOREIGN KEY (cd_ref)
REFERENCES taxonomie.bib_noms (cd_nom) MATCH FULL
ON DELETE NO ACTION ON UPDATE CASCADE ;

-- object: fk_t_media_bib_types_media | type: CONSTRAINT
ALTER TABLE taxonomie.t_medias DROP CONSTRAINT IF EXISTS fk_t_media_bib_types_media CASCADE;
ALTER TABLE taxonomie.t_medias ADD CONSTRAINT fk_t_media_bib_types_media FOREIGN KEY (id_type)
REFERENCES taxonomie.bib_types_media (id_type) MATCH FULL
ON DELETE NO ACTION ON UPDATE CASCADE;

INSERT INTO taxonomie.bib_attributs (id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, regne, group2_inpn, id_theme, ordre) VALUES (100, 'atlas_description', 'Description', '{}', false, 'Donne une description du taxon pour l''atlas', 'text', 'textarea', NULL, NULL, 2, 100);
INSERT INTO taxonomie.bib_attributs (id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, regne, group2_inpn, id_theme, ordre) VALUES (101, 'atlas_commentaire', 'Commentaire', '{}', false, 'Commentaire contextualisé sur le taxon pour GeoNature-atlas', 'text', 'textarea', NULL, NULL, 2, 101);
INSERT INTO taxonomie.bib_attributs (id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, regne, group2_inpn, id_theme, ordre) VALUES (102, 'atlas_milieu', 'Milieu', '{"values":["Landes","Milieux humides","Alpages"]}', false, 'Habitat, milieu principal du taxon', 'text', 'select', NULL, NULL, 2, 102);
INSERT INTO taxonomie.bib_attributs (id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, regne, group2_inpn, id_theme, ordre) VALUES (103, 'atlas_corologie', 'Corologie', '["Méditéranéenne","Alpine","Océanique"]', false, 'Distribution, répartition, région à grande échelle du taxon', 'text', 'select', NULL, NULL, 2, 103);


GRANT USAGE ON SCHEMA utilisateurs TO geonatatlas;
GRANT USAGE ON SCHEMA synthese TO geonatatlas;
GRANT USAGE ON SCHEMA taxonomie TO geonatatlas;
GRANT USAGE ON SCHEMA meta TO geonatatlas;
GRANT USAGE ON SCHEMA layers TO geonatatlas;
GRANT USAGE ON SCHEMA public TO geonatatlas;

GRANT SELECT ON TABLE utilisateurs.bib_droits TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.bib_unites TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.cor_role_droit_application TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.cor_role_menu TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.cor_roles TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.t_applications TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.t_menus TO geonatatlas;
GRANT SELECT ON TABLE utilisateurs.t_roles TO geonatatlas;

GRANT SELECT ON TABLE synthese.bib_criteres_synthese TO geonatatlas;
GRANT SELECT ON TABLE synthese.bib_sources TO geonatatlas;
GRANT SELECT ON TABLE synthese.cor_unite_synthese TO geonatatlas;
GRANT SELECT ON TABLE synthese.cor_zonesstatut_synthese TO geonatatlas;
GRANT SELECT ON TABLE synthese.syntheseff TO geonatatlas;

GRANT SELECT ON TABLE taxonomie.bib_attributs TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_listes TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_noms TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_habitats TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_rangs TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_statuts TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.cor_taxon_attribut TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.cor_nom_liste TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref_protection_articles TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref_protection_especes TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.t_medias TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_types_media TO geonatatlas;

GRANT SELECT ON TABLE meta.bib_lots TO geonatatlas;
GRANT SELECT ON TABLE meta.bib_programmes TO geonatatlas;
GRANT SELECT ON TABLE meta.t_precisions TO geonatatlas;
GRANT SELECT ON TABLE meta.t_protocoles TO geonatatlas;

GRANT SELECT ON TABLE layers.bib_typeszones TO geonatatlas;
GRANT SELECT ON TABLE layers.l_communes TO geonatatlas;
GRANT SELECT ON TABLE layers.l_secteurs TO geonatatlas;
GRANT SELECT ON TABLE layers.l_zonesstatut TO geonatatlas;

GRANT SELECT ON TABLE public.cor_boolean TO geonatatlas;


