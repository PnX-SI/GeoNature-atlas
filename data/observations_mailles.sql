-- Creation de la VM des observations de chaque taxon par mailles...

CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
    SELECT 
      obs.id_observation,
      obs.cd_ref,
      cor.id_area as id_maille,
      cor.geojson_4326 as geojson_maille,
      st_transform(cor.geom, 3857) as the_geom,
      cor.type_code as type_code,
date_part('year', dateobs) as annee,
obs.dateobs
FROM atlas.vm_observations obs
JOIN atlas.vm_cor_area_synthese cor ON cor.id_synthese = obs.id_observation AND cor.is_blurred_geom IS TRUE
;


create index on atlas.vm_observations_mailles (id_maille);
create index on atlas.vm_observations_mailles (cd_ref);
-- create index on atlas.vm_observations_mailles (geojson_maille);
-- This line produces this error :
-- SQL Error [54000]: ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191
