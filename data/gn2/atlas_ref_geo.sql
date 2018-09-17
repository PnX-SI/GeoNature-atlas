--################################
--###COMMUNES
--################################
DROP MATERIALIZED VIEW atlas.vm_communes;

CREATE MATERIALIZED VIEW atlas.vm_communes AS
 SELECT c.area_code as insee,
    c.area_name as commune_maj,
    st_transform(c.geom, 3857) as the_geom,
    st_asgeojson(st_transform(c.geom, 4326)) AS commune_geojson
   FROM ref_geo.l_areas c
   JOIN  ref_geo.li_municipalities m ON c.id_area = m.id_area
   WHERE id_type=101 and enable=true AND apa=true
WITH DATA;


-- Index: atlas.index_gist_vm_communes_the_geom

-- DROP INDEX atlas.index_gist_vm_communes_the_geom;

CREATE INDEX index_gist_vm_communes_the_geom
  ON atlas.vm_communes
  USING gist
  (the_geom);

-- Index: atlas.vm_communes_insee_idx

-- DROP INDEX atlas.vm_communes_insee_idx;

CREATE UNIQUE INDEX vm_communes_insee_idx
  ON atlas.vm_communes
  USING btree
  (insee COLLATE pg_catalog."default");

DROP TABLE atlas.l_communes;

--################################
--################################
--###Mailles
--################################
--################################

DROP TABLE atlas.t_mailles_territoire;
DROP TABLE atlas.t_mailles_5;


CREATE MATERIALIZED VIEW atlas.t_mailles_territoire AS
SELECT st_transform(c.geom, 3857) as the_geom,
    st_asgeojson(st_transform(c.geom, 4326)) AS geojson_maille,
    id_area as id_maille
FROM ref_geo.l_areas c
JOIN ref_geo.bib_areas_types t
ON t.id_type = c.id_type
WHERE t.type_code = :type_maille;



--################################
--################################
--###Territoires
--################################
--################################


DROP TABLE atlas.t_layer_territoire;

CREATE MATERIALIZED VIEW atlas.t_layer_territoire AS
WITH d AS (
	SELECT st_union(geom) , b.type_name
	FROM ref_geo.l_areas l
	JOIN ref_geo.bib_areas_types b USING(id_type)
	WHERE l.id_type =24
	GROUP BY b.type_name
)
SELECT
 1::int as gid,
 type_name as nom,
 st_area(st_union)/10000 as surf_ha,
 st_area(st_union)/1000000 as surf_km2,
 ST_Perimeter(st_union)/1000 as perim_km,
 st_transform(st_union, 3857) as  the_geom
FROM d;
