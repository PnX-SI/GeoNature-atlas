DROP MATERIALIZED VIEW atlas.t_mailles_territoire;

-- MV for having only meshs of the territory
CREATE MATERIALIZED VIEW atlas.t_mailles_territoire
AS SELECT c.geom AS the_geom,
st_asgeojson(st_transform(c.geom, 4326)) AS geojson_maille,
c.id_area AS id_maille
FROM ref_geo.l_areas c
JOIN ref_geo.bib_areas_types t ON t.id_type = c.id_type
JOIN atlas.t_layer_territoire mt ON ST_intersects(c.geom,st_transform(mt.the_geom, 2154))
WHERE c.enable = true AND t.type_code = :type_maille;

CREATE UNIQUE INDEX t_mailles_territoire_id_maille_idx ON atlas.t_mailles_territoire USING btree (id_maille);