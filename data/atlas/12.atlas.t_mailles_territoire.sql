DROP TABLE IF EXISTS atlas.t_mailles_territoire;

-- MV for having only meshs of the territory
CREATE TABLE atlas.t_mailles_territoire AS
    SELECT
        st_transform(c.geom, 4326) AS the_geom,
        st_asgeojson(st_transform(c.geom, 4326)) AS geojson_maille,
        c.id_area AS id_maille
    FROM ref_geo.l_areas AS c
        JOIN ref_geo.bib_areas_types AS t
            ON t.id_type = c.id_type
    WHERE c.enable = true
        AND t.type_code = :type_maille
        AND EXISTS (
            SELECT 'X'
            FROM atlas.vm_subdivided_area AS sa
            WHERE sa.code = 'territory'
                AND st_intersects(c.geom, st_transform(sa.geom, find_srid('ref_geo', 'l_areas', 'geom')))
        );

CREATE UNIQUE INDEX t_mailles_territoire_id_maille_idx ON atlas.t_mailles_territoire USING btree (id_maille);
