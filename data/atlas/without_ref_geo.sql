CREATE INDEX index_gist_t_layer_territoire ON atlas.t_layer_territoire USING gist(the_geom);
CREATE INDEX index_gist_t_layers_communes ON atlas.l_communes USING gist (the_geom);

CREATE TABLE atlas.t_mailles_territoire as
SELECT m.geom AS the_geom, ST_AsGeoJSON(st_transform(m.geom, 4326)) as geojson_maille
FROM atlas.t_mailles_t_mailles_source m, atlas.t_layer_territoire t
WHERE ST_Intersects(m.geom, t.the_geom);

CREATE INDEX index_gist_t_mailles_territoire ON atlas.t_mailles_territoire USING gist (the_geom);
ALTER TABLE atlas.t_mailles_territoire ADD COLUMN id_maille serial; 
ALTER TABLE atlas.t_mailles_territoire ADD PRIMARY KEY (id_maille);