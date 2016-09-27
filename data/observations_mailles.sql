CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_observation,
    m.id_maille,
    m.the_geom,
    st_asgeojson(st_transform(m.the_geom, 4326)) AS geojson_maille
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_intersects(obs.the_geom_point, st_transform(m.the_geom, 3857))
WITH DATA;


create unique index on atlas.vm_observations_mailles (id_synthese);
create index on atlas.vm_observations_mailles (id_maille);
create index on atlas.vm_observations_mailles (cd_ref);
create index on atlas.vm_observations_mailles (geojson_maille);
CREATE INDEX index_gist_atlas_vm_observations_mailles_geom ON atlas.vm_observations_mailles USING gist (the_geom);
