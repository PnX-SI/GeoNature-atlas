-- Refresh all Atlas Materialized views

-- Enable timing
\timing

BEGIN ;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_taxref:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxref;

\echo '----------------------------------------------------------------'
\echo 'Refreshing t_layer_territoire:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.t_layer_territoire;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_bib_areas_types:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_bib_areas_types;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_areas:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_areas;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_l_areas:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_l_areas;

\echo '----------------------------------------------------------------'
\echo 'Refreshing bdc_statut_cor_text_area:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.bdc_statut_cor_text_area;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_bdc_statut:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_bdc_statut;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_taxon_statut_area:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_statut_area;

\echo '----------------------------------------------------------------'
\echo 'Refreshing status_areas_buffered:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.status_areas_buffered;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_taxon_statut_area_spread:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_statut_area_spread;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_observations:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_area_synthese:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_area_synthese;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_taxons:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_altitudes:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_altitudes;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_search_taxon:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_search_taxon;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_mois:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_mois;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_medias:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_medias;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_taxon_attribut:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_attribut;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_taxons_plus_observes:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons_plus_observes;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_taxon_organism:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_organism;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_taxon_area:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_area;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_cor_maille_observation:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_maille_observation;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_area_stats:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_area_stats_by_taxonomy_group:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats_by_taxonomy_group;

\echo '----------------------------------------------------------------'
\echo 'Refreshing vm_area_stats_by_organism:'
REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats_by_organism;

\echo '----------------------------------------------------------------'
\echo 'COMMIT if all is ok:'
COMMIT;
