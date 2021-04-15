BEGIN;


-- Table: atlas.t_cache
DROP TABLE IF EXISTS atlas.t_cache;

CREATE TABLE atlas.t_cache (
  label VARCHAR(250) NOT NULL PRIMARY KEY,
  cache TEXT NOT NULL,
  meta_create_date TIMESTAMP NOT NULL DEFAULT NOW()
);

GRANT SELECT, UPDATE, INSERT ON TABLE atlas.t_cache TO geonatatlas;


-- Materialized View: atlas.vm_stats
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_stats;

CREATE MATERIALIZED VIEW atlas.vm_stats AS
    SELECT 'observations' AS label, COUNT(*) AS result FROM atlas.vm_observations
    UNION
    SELECT 'municipalities' AS label, COUNT(*) AS result FROM atlas.vm_communes
    UNION 
    SELECT 'taxons' AS label, COUNT(DISTINCT cd_ref) AS result FROM atlas.vm_taxons
    UNION
    SELECT 'pictures' AS label, COUNT (DISTINCT id_media) AS result
    FROM atlas.vm_medias AS m 
        JOIN atlas.vm_taxons AS t ON ( t.cd_ref = m.cd_ref )
    WHERE id_type IN (1, 2)
WITH DATA ;

CREATE UNIQUE INDEX ON atlas.vm_stats (label);

GRANT SELECT ON TABLE atlas.vm_stats TO geonatatlas;


--Function : RefreshAllMaterializedViews('atlas')
CREATE OR REPLACE FUNCTION RefreshAllMaterializedViews(schema_arg TEXT DEFAULT 'public')
RETURNS INT AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;
    FOR r IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
    LOOP
        RAISE NOTICE 'Refreshing %.%', schema_arg, r.matviewname;
        --EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || r.matviewname; --Si vous utilisez une version inférieure à PostgreSQL 9.4
        EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || schema_arg || '.' || r.matviewname;
    END LOOP;

    IF schema_arg = 'atlas' THEN
        RAISE NOTICE 'Deleting cache in atlas.t_cache' ;
        TRUNCATE atlas.t_cache ;
    END IF ;

    RETURN 1;
END
$$ LANGUAGE plpgsql;

-- Function : atlas.refresh_materialized_view_data()
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data()
RETURNS VOID AS $$
BEGIN

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations_mailles;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_mois;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_altitudes;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_attribut;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_search_taxon;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_medias;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons_plus_observes;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_stats;

  TRUNCATE atlas.t_cache ;
END
$$ LANGUAGE plpgsql;


COMMIT;