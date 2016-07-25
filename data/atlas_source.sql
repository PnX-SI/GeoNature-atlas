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
GRANT SELECT ON TABLE taxonomie.bib_filtres TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_listes TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxons TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_habitats TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_rangs TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.bib_taxref_statuts TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.cor_taxon_attribut TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.cor_taxon_liste TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref_protection_articles TO geonatatlas;
GRANT SELECT ON TABLE taxonomie.taxref_protection_especes TO geonatatlas;

GRANT SELECT ON TABLE meta.bib_lots TO geonatatlas;
GRANT SELECT ON TABLE meta.bib_programmes TO geonatatlas;
GRANT SELECT ON TABLE meta.t_precisions TO geonatatlas;
GRANT SELECT ON TABLE meta.t_protocoles TO geonatatlas;

GRANT SELECT ON TABLE layers.bib_typeszones TO geonatatlas;
GRANT SELECT ON TABLE layers.l_communes TO geonatatlas;
GRANT SELECT ON TABLE layers.l_secteurs TO geonatatlas;
GRANT SELECT ON TABLE layers.l_zonesstatut TO geonatatlas;

GRANT SELECT ON TABLE public.cor_boolean TO geonatatlas;


