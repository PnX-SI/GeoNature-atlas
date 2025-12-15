


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
        -- on fait un buffer négatif de 10 m sur les département pour éviter la double
        -- intersections des zonages administratifs (eg: commune). 
        st_intersects(st_buffer(dep.geom_local, -10), vla.geom_local)
        WHERE b.type_code in (SELECT * FROM string_to_table(:'type_code', ','))
        -- On laisse volontairement l'autointersection département  - département pour les fiche territoire des départements !
    UNION
        -- on prend ce qu'il y avait déjà dans ref_geo.l_areas
        SELECT id_area as id_area, id_area_group as id_area_parent from ref_geo.cor_areas;
                    
CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area_parent);

CREATE INDEX ON atlas.vm_cor_areas
    USING btree (id_area);
