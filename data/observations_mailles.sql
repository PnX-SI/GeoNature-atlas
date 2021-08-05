CREATE VIEW ref_geo.mon_territoire AS
SELECT st_transform(la.geom, 3857) AS geom
FROM ref_geo.l_areas la
WHERE la.area_name = 'ALCOTRA-France';

DROP MATERIALIZED VIEW atlas.t_mailles_territoire;

CREATE MATERIALIZED VIEW atlas.t_mailles_territoire
AS SELECT c.geom AS the_geom,
st_asgeojson(st_transform(c.geom, 4326)) AS geojson_maille,
c.id_area AS id_maille
FROM ref_geo.l_areas c
JOIN ref_geo.bib_areas_types t ON t.id_type = c.id_type
JOIN ref_geo.mon_territoire mt ON ST_intersects(c.geom,st_transform(mt.geom, 2154))
WHERE c.enable = true AND c.id_type = 27;

CREATE UNIQUE INDEX t_mailles_territoire_id_maille_idx ON atlas.t_mailles_territoire USING btree (id_maille);

CREATE MATERIALIZED VIEW atlas.vm_observations_mailles
AS SELECT obs.cd_ref,
obs.id_observation,
m.id_maille,
m.geojson_maille,
date_part('year', dateobs) as annee
FROM atlas.vm_observations obs
JOIN atlas.t_mailles_territoire m ON st_intersects(st_transform(obs.the_geom_point, 2154), m.the_geom)
WITH DATA;