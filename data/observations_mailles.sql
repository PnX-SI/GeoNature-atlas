-- Creation de la VM des observations de chaque taxon par mailles...

-- Materialized View: atlas.vm_observations_mailles
CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_observation,
    m.id_maille,
    m.geojson_maille,
    date_part('year', dateobs) as annee
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_intersects(obs.the_geom_point, m.the_geom)
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations_mailles (id_observation);
CREATE INDEX ON atlas.vm_observations_mailles (id_maille);
CREATE INDEX ON atlas.vm_observations_mailles (cd_ref);
CREATE INDEX ON atlas.vm_observations_mailles (geojson_maille);
CREATE INDEX ON atlas.vm_observations_mailles (annee);
CREATE UNIQUE INDEX ON atlas.vm_observations_mailles USING btree (id_observation, geojson_maille) ;