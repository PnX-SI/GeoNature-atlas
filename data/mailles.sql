ALTER TABLE atlas.t_mailles
  ADD column id_maille serial;
  CREATE INDEX index_gist_t_mailles ON atlas.t_mailles USING gist (geom);


CREATE materialized view atlas.vm_observations_mailles AS


SELECT obs.cd_ref,
count(obs.id_synthese) as nb_observations,
m.id_maille,
obs.the_geom_point,
st_asgeojson(st_transform(m.geom,4326)) AS geojson_maille
FROM atlas.vm_observations obs
JOIN atlas.t_mailles m ON ST_Intersects(obs.the_geom_point, st_transform(m.geom,3857))
group by obs.cd_ref, m.id_maille, geojson_maille, obs.the_geom_point ;


ALTER TABLE atlas.vm_observations_mailles
  OWNER TO geonatatlas;
create index on atlas.vm_observations_mailles (nb_observations);
create index on atlas.vm_observations_mailles (cd_ref);
CREATE INDEX index_gist_vm_observations_mailles ON atlas.vm_observations_mailles USING gist (the_geom_point);