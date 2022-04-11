BEGIN;

CREATE INDEX ON atlas.vm_observations_mailles (geojson_maille);
CREATE INDEX ON atlas.vm_observations_mailles (annee);
CREATE UNIQUE INDEX ON atlas.vm_observations_mailles USING btree(id_observation, geojson_maille) ;

COMMIT;