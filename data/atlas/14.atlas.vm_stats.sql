-- Materialized View: atlas.vm_stats
-- DROP MATERIALIZED VIEW IF EXISTS atlas.vm_stats;
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
    WHERE id_type IN (1, 2) ;

CREATE UNIQUE INDEX ON atlas.vm_stats (label);