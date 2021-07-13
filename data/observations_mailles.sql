-- Creation de la VM des observations de chaque taxon par mailles...

CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_observation,
    m.id_maille,
    m.id_type,
    m.geojson_maille,
    date_part('year', dateobs) as annee
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_equals(obs.the_geom_point, m.the_geom)
WITH DATA;

create unique index on atlas.vm_observations_mailles (id_observation);
create index on atlas.vm_observations_mailles (id_maille);
create index on atlas.vm_observations_mailles (cd_ref);
-- create index on atlas.vm_observations_mailles (geojson_maille);
-- This line produces this error :
-- SQL Error [54000]: ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191
