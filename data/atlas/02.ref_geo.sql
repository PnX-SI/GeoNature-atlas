-- +-----------------------------------------------------------------------------------------------+
-- vm_bib_areas_types
CREATE MATERIALIZED VIEW atlas.vm_bib_areas_types AS
    SELECT
        id_type,
        type_code,
        type_name,
        "type_desc",
        size_hierarchy
    FROM ref_geo.bib_areas_types bat
    WHERE bat.type_code IN (SELECT * FROM string_to_table(:'type_code', ','))
        OR bat.type_code = :'type_maille'
        OR bat.id_type IN (SELECT id_area_type FROM gn_sensitivity.cor_sensitivity_area_type)
        OR bat.type_code = 'DEP' -- Mandatory for status (protection, red lists) 
    
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_bib_areas_types
    USING btree (id_type);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_code);

CREATE INDEX ON atlas.vm_bib_areas_types
    USING btree (type_name);


-- +-----------------------------------------------------------------------------------------------+
-- l_areas
CREATE MATERIALIZED VIEW atlas.vm_l_areas AS
    SELECT
        a.id_area,
        a.area_code,
        a.area_name,
        a.id_type,
        a.geom AS geom_local,
        a.geom_4326 AS the_geom,
        st_asgeojson(a.geom_4326) AS area_geojson,
        a."description"
    FROM ref_geo.l_areas AS a
        JOIN atlas.vm_bib_areas_types AS bat ON a.id_type = bat.id_type
    WHERE "enable" = TRUE
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_l_areas
    USING btree (id_area);

CREATE INDEX ON atlas.vm_l_areas
    USING gist (the_geom);

CREATE INDEX ON atlas.vm_l_areas
    USING gist (geom_local);

CREATE INDEX ON atlas.vm_l_areas
    USING btree (area_code);


-- +-----------------------------------------------------------------------------------------------+
-- vm_cor_areas
CREATE MATERIALIZED VIEW atlas.vm_cor_areas AS
    WITH dep AS (
        SELECT
            vla.id_area,
            ST_SimplifyPreserveTopology(vla.geom_local, 100) AS geom_local_simplified,
            st_buffer(
                ST_SimplifyPreserveTopology(vla.geom_local, 100),
                200
            ) AS geom_local_simplified_buffered
        FROM atlas.vm_l_areas AS vla
            JOIN atlas.vm_bib_areas_types AS b USING(id_type)
        WHERE b.type_code = 'DEP'
    ),
    areas AS (
        SELECT
            vla.id_area,
            ST_SimplifyPreserveTopology(vla.geom_local, 100) AS geom_local_simplified
        FROM atlas.vm_l_areas AS vla
            JOIN atlas.vm_bib_areas_types AS b USING(id_type)
        WHERE b.type_code IN (SELECT * FROM string_to_table(:'type_code', ','))
    )
    SELECT
        a.id_area,
        d.id_area AS id_area_parent
    FROM areas AS a
        JOIN dep AS d
            ON (
                st_intersects(d.geom_local_simplified, a.geom_local_simplified)
                AND st_within(a.geom_local_simplified, d.geom_local_simplified_buffered)
            )
    UNION
        SELECT
            id_area,
            id_area_group AS id_area_parent
        FROM ref_geo.cor_areas
    ;
    -- We are intentionally leaving the department-department intersection for the departmental territory sheets!

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area_parent);

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area);
