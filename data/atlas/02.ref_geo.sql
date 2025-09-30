
-- +-----------------------------------------------------------------------------------------------+
-- t_layer_territoire

-- If t_layer_territoire is a table, drop it. If it is a view, raise a notice and continue.
DO $$
BEGIN
	DROP TABLE atlas.t_layer_territoire;
EXCEPTION WHEN others THEN
	RAISE NOTICE 'view atlas.t_layer_territoire does not exist';
END$$;


CREATE MATERIALIZED VIEW atlas.t_layer_territoire AS
    WITH territory AS (
        SELECT
            t.type_name,
            st_union(a.geom) AS geom -- Don't use projected SRID like 4326
        FROM ref_geo.l_areas AS a
            JOIN ref_geo.bib_areas_types AS t
                USING(id_type)
        WHERE REPLACE(t.type_code, ' ', '_') = :'type_territoire'
            AND a."enable" = TRUE
        GROUP BY t.type_name
    )
    SELECT
        1::int AS gid,
        type_name AS nom,
        st_area(geom)/10000 AS surf_ha,
        st_area(geom)/1000000 AS surf_km2,
        ST_Perimeter(geom)/1000 AS perim_km,
        st_transform(geom, 4326) AS the_geom -- Using ST_Transform to convert to 4326 is faster than using ST_Union on geom_4326.
    FROM territory
WITH DATA;

CREATE INDEX ON atlas.t_layer_territoire
    USING gist (the_geom);

CREATE UNIQUE INDEX ON atlas.t_layer_territoire
    USING btree (gid);


-- +-----------------------------------------------------------------------------------------------+
-- vm_bib_areas_types
CREATE MATERIALIZED VIEW atlas.vm_bib_areas_types AS
    SELECT
        id_type,
        type_code,
        type_name,
        "type_desc"
    FROM ref_geo.bib_areas_types
WITH DATA;

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (id_type);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_code);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_name);


-- +-----------------------------------------------------------------------------------------------+
-- vm_cor_areas
CREATE MATERIALIZED VIEW atlas.vm_cor_areas AS
    SELECT
        id_area_group,
        id_area
    FROM ref_geo.cor_areas
WITH DATA;

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area_group);

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area);


-- +-----------------------------------------------------------------------------------------------+
-- l_areas
-- création de la vm l_areas à partir du ref_geo
CREATE MATERIALIZED VIEW atlas.vm_l_areas AS
    SELECT
        a.id_area AS id_area,
        a.area_code AS area_code,
        a.area_name AS area_name,
        a.id_type AS id_type,
        a.geom_local AS geom_local,
        a.geom_4326 AS the_geom,
        st_asgeojson(a.geom_4326) AS area_geojson,
        a.description AS "description"
    FROM ref_geo.l_areas AS a
        JOIN ref_geo.bib_areas_types AS bat
            ON a.id_type = bat.id_type
        JOIN atlas.t_layer_territoire AS t
            ON st_intersects(t.the_geom, a.geom_4326)
    WHERE "enable" = TRUE
        AND (
            bat.type_code IN (SELECT * FROM string_to_table(:'type_code', ','))
            OR bat.type_code = :'type_maille'
            OR a.id_type IN (SELECT id_area_type FROM synthese.cor_sensitivity_area_type)
            OR bat.type_code = 'DEP' -- necessaire pour les statuts (protection, listes rouge)
        )
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_l_areas
    USING btree (id_area);

CREATE INDEX ON atlas.vm_l_areas
    USING gist (the_geom);

CREATE INDEX ON atlas.vm_l_areas
    USING btree (area_code);


-- +-----------------------------------------------------------------------------------------------+
-- Function refresh_materialized_view_ref_geo()
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_ref_geo()
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
    -- Rafraichissement des vues contenant les données de l'atlas
    BEGIN
        REFRESH MATERIALIZED VIEW atlas.t_layer_territoire ;
    END
$function$ ;
