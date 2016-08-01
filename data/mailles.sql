CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_synthese,
    m.id_maille,
    m.geom,
    st_asgeojson(st_transform(m.geom, 4326)) AS geojson_maille
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_intersects(obs.the_geom_point, st_transform(m.geom, 3857))
WITH DATA;


create unique index on atlas.vm_observations_mailles (id_synthese);
create index on atlas.vm_observations_mailles (id_maille);
create index on atlas.vm_observations_mailles (cd_ref);
create index on atlas.vm_observations_mailles (geojson_maille);
create index on atlas.vm_observations_mailles (geom);