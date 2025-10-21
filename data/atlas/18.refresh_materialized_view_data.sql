-- TODO: normalize function name : refresh_all_materialized_views()
CREATE OR REPLACE FUNCTION RefreshAllMaterializedViews(schema_arg TEXT DEFAULT 'public')
    RETURNS INT
    LANGUAGE plpgsql
AS
$function$
    -- Fonction pour rafraichir toutes les vues matérialisées d'un schéma
    -- Usage : SELECT RefreshAllMaterializedViews('atlas');
    DECLARE
        r RECORD;

    BEGIN
        RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;

        FOR r IN (SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg)
        LOOP
            RAISE NOTICE 'Refreshing %.%', schema_arg, r.matviewname;
            --EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || r.matviewname;
            --Si vous utilisez une version inférieure à PostgreSQL 9.4
            EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || schema_arg || '.' || r.matviewname;
        END LOOP;

        RETURN 1;
    END
$function$ ;


CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data()
    RETURNS VOID
    LANGUAGE plpgsql
AS
$function$
    -- Rafraichissement des vues contenant les données de l'atlas
    BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_area_synthese;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_altitudes;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_search_taxon;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_mois;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_medias;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_attribut;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons_plus_observes;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_organism;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_maille_observation;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats_by_taxonomy_group;
        REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_area_stats_by_organism;
    END
$function$ ;
