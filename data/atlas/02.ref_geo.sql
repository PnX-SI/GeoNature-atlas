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

CREATE UNIQUE INDEX ON atlas.t_layer_territoire
    USING btree (gid);

CREATE INDEX ON atlas.t_layer_territoire
    USING gist (the_geom);


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
        JOIN ref_geo.bib_areas_types AS bat
            ON a.id_type = bat.id_type
        JOIN atlas.t_layer_territoire AS t
            ON st_intersects(t.the_geom, a.geom_4326)
    WHERE "enable" = TRUE
        AND (
            bat.type_code IN (SELECT * FROM string_to_table(:'type_code', ','))
            OR bat.type_code = :'type_maille'
            OR a.id_type IN (SELECT id_area_type FROM gn_sensitivity.cor_sensitivity_area_type)
            OR bat.type_code = 'DEP' -- Mandatory for status (protection, red lists)
        )
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



-- +-----------------------------------------------------------------------------------------------+
-- vm_cor_areas
CREATE MATERIALIZED VIEW atlas.vm_cor_areas AS
    with dep as (
    SELECT * 
    FROM atlas.vm_l_areas vla
    JOIN atlas.vm_bib_areas_types b USING(id_type)
    where b.type_code = 'DEP'
    )
        SELECT vla.id_area, dep.id_area as id_area_parent
        FROM atlas.vm_l_areas vla
        JOIN atlas.vm_bib_areas_types b USING(id_type)
        JOIN dep on 
        st_intersects(dep.geom_local, vla.geom_local) AND 
                st_within(vla.geom_local, st_buffer(dep.geom_local, 100))
        WHERE b.type_code in (SELECT * FROM string_to_table(:'type_code', ','))
    UNION
        SELECT id_area as id_area, id_area_group as id_area_parent from ref_geo.cor_areas;
        -- On laisse volontairement l'autointersection département  - département pour les fiche territoire des départements !
                    
CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area_parent);

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area);
