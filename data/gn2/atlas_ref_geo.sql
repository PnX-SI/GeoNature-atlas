--################################
--################################
--###Territoires
--################################
--################################

DO $$
BEGIN
	DROP TABLE atlas.t_layer_territoire;
EXCEPTION WHEN others THEN
	RAISE NOTICE 'view atlas.t_layer_territoire does not exist';
END$$;


CREATE MATERIALIZED VIEW atlas.t_layer_territoire AS
    WITH d AS (
        SELECT
            st_union(geom),
            b.type_name
        FROM ref_geo.l_areas AS l
            JOIN ref_geo.bib_areas_types AS b
                USING(id_type)
        WHERE REPLACE(b.type_code, ' ', '_') = :'type_territoire'
        GROUP BY b.type_name
    )
    SELECT
        1::int AS gid,
        type_name AS nom,
        st_area(st_union)/10000 AS surf_ha,
        st_area(st_union)/1000000 AS surf_km2,
        ST_Perimeter(st_union)/1000 AS perim_km,
        st_transform(st_union, 4326) AS  the_geom
    FROM d;

CREATE INDEX ON atlas.t_layer_territoire
    USING gist (the_geom);

CREATE UNIQUE INDEX ON atlas.t_layer_territoire
    USING btree (gid);


CREATE MATERIALIZED VIEW atlas.vm_bib_areas_types AS
    SELECT
        t.id_type,
        t.type_code,
        t.type_name,
        t.type_desc
    FROM ref_geo.bib_areas_types AS t
    WHERE type_code IN (SELECT * FROM string_to_table(:type_code, ','));

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (id_type);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_code);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_name);


-- Suppression de la VM atlas.vm_cor_areas si existe
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_cor_areas CASCADE;

CREATE MATERIALIZED VIEW atlas.vm_cor_areas AS
    SELECT
        id_area_group,
        id_area
    FROM ref_geo.cor_areas;

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area_group);

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area);


-- Suppression si temporaire des areas la table existe
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_l_areas;

-- création de la vm l_areas à partir des communes du ref_geo
CREATE MATERIALIZED VIEW atlas.vm_l_areas AS
    SELECT
        a.id_area AS id_area,
        a.area_code AS area_code,
        a.area_name AS area_name,
        a.id_type AS id_type,
        st_transform(a.geom, 4326) AS the_geom,
        st_asgeojson(st_transform(a.geom, 4326)) AS area_geojson,
        a.description AS "description"
    FROM ref_geo.l_areas AS a
        JOIN ref_geo.bib_areas_types AS b
            ON a.id_type = b.id_type
        JOIN atlas.t_layer_territoire AS layer
            ON st_intersects(layer.the_geom, a.geom_4326)
    WHERE "enable" = TRUE
        AND (
            b.type_code IN (SELECT * FROM string_to_table(:type_code, ','))
            OR a.id_type IN (SELECT id_area_type FROM synthese.cor_sensitivity_area_type)
        )
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_l_areas
    USING btree (id_area);

CREATE INDEX ON atlas.vm_l_areas
    USING gist (the_geom);

CREATE INDEX ON atlas.vm_l_areas
    USING btree (area_code);


-- Rafraichissement des vues contenant les données de l'atlas
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_ref_geo()
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
    BEGIN
        REFRESH MATERIALIZED VIEW atlas.t_layer_territoire ;
    END
$function$ ;




