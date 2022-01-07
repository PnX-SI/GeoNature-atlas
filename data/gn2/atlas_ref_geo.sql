--################################
--###MAILLES
--################################

DO $$
BEGIN
	DROP TABLE atlas.t_mailles_territoire;
EXCEPTION WHEN others THEN
	RAISE NOTICE 'view atlas.t_mailles_territoire does not exist';
END$$;

--################################
--###TERRITOIRE
--################################

DO $$
BEGIN
	DROP TABLE atlas.t_layer_territoire;
EXCEPTION WHEN others THEN
	RAISE NOTICE 'view atlas.t_layer_territoire does not exist';
END$$;


CREATE MATERIALIZED VIEW atlas.t_layer_territoire AS
WITH d AS (
	SELECT st_union(geom) AS the_geom, b.type_name
	FROM ref_geo.l_areas l
	JOIN ref_geo.bib_areas_types b USING(id_type)
	WHERE REPLACE(b.type_code, ' ', '_') = :type_territoire
  AND l.enable = true
  AND l.id_area = '11267'
	GROUP BY b.type_name
)
SELECT
 1::int as gid,
 type_name as nom,
 st_area(the_geom)/10000 as surf_ha,
 st_area(the_geom)/1000000 as surf_km2,
 ST_Perimeter(the_geom)/1000 as perim_km,
 st_transform(the_geom, 4326) as  the_geom
FROM d;

CREATE INDEX index_gist_t_layer_territoire_the_geom
  ON atlas.t_layer_territoire
  USING gist
  (the_geom);
  
CREATE UNIQUE INDEX t_layer_territoire_gid_idx
  ON atlas.t_layer_territoire
  USING btree (gid);


--################################
--###ENTREE GEOGRAPHIQUE
--################################

-- Suppression temporaire si la table de l'entrée géographique existe
DO $$
BEGIN
	DROP MATERIALIZED VIEW atlas.vm_geo_entry;
EXCEPTION WHEN others THEN
	RAISE NOTICE 'view atlas.vm_geo_entry does not exist';
END$$;

-- création de la vm geo_entry à partir du ref_geo
CREATE MATERIALIZED VIEW atlas.vm_geo_entry AS
  SELECT a.area_code as geo_entry_id,
    a.area_name as geo_entry_name,
    st_transform(a.geom, 4326) as the_geom,
    st_asgeojson(st_transform(a.geom, 4326)) AS geo_entry_geojson
  FROM ref_geo.l_areas a
   JOIN ref_geo.bib_areas_types b USING(id_type)
   JOIN atlas.t_layer_territoire t ON ST_CONTAINS(ST_BUFFER(t.the_geom,200), st_transform(a.geom,4326))
	WHERE b.type_code = :type_geo_entry
  --AND a.enable = true
  AND a.id_area = '11267'
WITH DATA;

CREATE INDEX index_gist_geo_entry_the_geom
  ON atlas.vm_geo_entry
  USING gist
  (the_geom);


CREATE UNIQUE INDEX geo_entry_id_idx
  ON atlas.vm_geo_entry
  USING btree
  (geo_entry_id COLLATE pg_catalog."default");


-- Rafraichissement des vues contenant les données de l'atlas
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_ref_geo()
RETURNS VOID AS $$
BEGIN

  REFRESH MATERIALIZED VIEW atlas.t_layer_territoire;
  REFRESH MATERIALIZED VIEW atlas.t_mailles_territoire;
  REFRESH MATERIALIZED VIEW atlas.vm_geo_entry;

END
$$ LANGUAGE plpgsql;
