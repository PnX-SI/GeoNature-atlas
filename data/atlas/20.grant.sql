-- Affectation de droits en lecture sur les VM à l'utilisateur de l'application ($user_pg)

SET search_path = public, pg_catalog;

GRANT USAGE ON SCHEMA atlas TO :reader_user ;

GRANT SELECT ON TABLE atlas.vm_taxref TO :reader_user ;
GRANT SELECT ON TABLE atlas.bib_taxref_rangs TO :reader_user ;
GRANT SELECT ON TABLE atlas.t_layer_territoire TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_bib_areas_types TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_areas TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_l_areas TO :reader_user ;
GRANT SELECT ON TABLE atlas.cor_sensitivity_area_type TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_area_synthese TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_observations TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_area_observation TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_taxons TO :reader_user ;
GRANT SELECT ON TABLE atlas.bib_altitudes TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_altitudes TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_search_taxon TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_mois TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_medias TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_taxon_attribut TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_taxons_plus_observes TO :reader_user ;
GRANT EXECUTE ON FUNCTION atlas.find_all_taxons_childs(integer) TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_taxon_organism TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_maille_observation TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_area_stats TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_area_stats_by_taxonomy_group TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_area_stats_by_organism TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_bdc_statut TO :reader_user ;
GRANT SELECT ON TABLE atlas.vm_cor_taxon_statut_area_spread TO :reader_user ;


