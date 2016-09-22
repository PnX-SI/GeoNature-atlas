GRANT USAGE ON SCHEMA utilisateurs TO geonatadmin;
GRANT USAGE ON SCHEMA synthese TO geonatadmin;
GRANT USAGE ON SCHEMA taxonomie TO geonatadmin;
GRANT USAGE ON SCHEMA meta TO geonatadmin;
GRANT USAGE ON SCHEMA layers TO geonatadmin;
GRANT USAGE ON SCHEMA public TO geonatadmin;

GRANT SELECT ON TABLE utilisateurs.bib_droits TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.bib_unites TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.cor_role_droit_application TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.cor_role_menu TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.cor_roles TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.t_applications TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.t_menus TO geonatadmin;
GRANT SELECT ON TABLE utilisateurs.t_roles TO geonatadmin;

GRANT SELECT ON TABLE synthese.bib_criteres_synthese TO geonatadmin;
GRANT SELECT ON TABLE synthese.bib_sources TO geonatadmin;
GRANT SELECT ON TABLE synthese.cor_unite_synthese TO geonatadmin;
GRANT SELECT ON TABLE synthese.cor_zonesstatut_synthese TO geonatadmin;
GRANT SELECT ON TABLE synthese.syntheseff TO geonatadmin;

GRANT SELECT ON TABLE taxonomie.bib_attributs TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_listes TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_noms TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_taxref_habitats TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_taxref_rangs TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_taxref_statuts TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.cor_taxon_attribut TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.cor_nom_liste TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.taxref TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.taxref_protection_articles TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.taxref_protection_especes TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.t_medias TO geonatadmin;
GRANT SELECT ON TABLE taxonomie.bib_types_media TO geonatadmin;

GRANT SELECT ON TABLE meta.bib_lots TO geonatadmin;
GRANT SELECT ON TABLE meta.bib_programmes TO geonatadmin;
GRANT SELECT ON TABLE meta.t_precisions TO geonatadmin;
GRANT SELECT ON TABLE meta.t_protocoles TO geonatadmin;

GRANT SELECT ON TABLE layers.bib_typeszones TO geonatadmin;
GRANT SELECT ON TABLE layers.l_communes TO geonatadmin;
GRANT SELECT ON TABLE layers.l_secteurs TO geonatadmin;
GRANT SELECT ON TABLE layers.l_zonesstatut TO geonatadmin;

GRANT SELECT ON TABLE public.cor_boolean TO geonatadmin;

