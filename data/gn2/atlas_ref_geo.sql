--################################
--###Communes
--################################

-- Suppression si temporaire des communes la table existe
DROP MATERIALIZED VIEW IF EXISTS atlas.l_communes;


-- création de la vm l_communes à partir des communes du ref_geo
CREATE MATERIALIZED VIEW atlas.l_communes AS
SELECT
    c.area_code                              AS insee
  , c.area_name                              AS commune_maj
  , st_transform(c.geom, 3857)               AS the_geom
  , st_asgeojson(st_transform(c.geom, 4326)) AS commune_geojson
FROM
    ref_geo.l_areas c
        JOIN ref_geo.li_municipalities m ON c.id_area = m.id_area
WHERE
    enable = TRUE
WITH DATA;

CREATE INDEX index_gist_l_communes_the_geom
    ON atlas.l_communes
        USING gist
        (the_geom);


CREATE UNIQUE INDEX l_communes_insee_idx
    ON atlas.l_communes
        USING btree
        (insee COLLATE pg_catalog."default");


--################################
--################################
--###Mailles
--################################
--################################

DROP TABLE IF EXISTS atlas.t_mailles_territoire;
DROP MATERIALIZED VIEW IF EXISTS atlas.t_mailles_territoire;

CREATE MATERIALIZED VIEW atlas.t_mailles_territoire AS
SELECT
    st_transform(c.geom, 3857)::GEOMETRY('MultiPolygon', 3857) AS the_geom
  , st_asgeojson(st_transform(c.geom, 4326))                   AS geojson_maille
  , id_area                                                    AS id_maille
FROM
    ref_geo.l_areas c
        JOIN ref_geo.bib_areas_types t
             ON t.id_type = c.id_type
WHERE
    t.type_code = :type_maille AND
    enable = TRUE;

CREATE UNIQUE INDEX t_mailles_territoire_id_maille_idx
    ON atlas.t_mailles_territoire
        USING btree(id_maille);


--################################
--################################
--###Territoires
--################################
--################################

DROP TABLE IF EXISTS atlas.t_layer_territoire;

CREATE MATERIALIZED VIEW atlas.t_layer_territoire AS
WITH
    d AS (
        SELECT st_union(geom), b.type_name
        FROM
            ref_geo.l_areas l
                JOIN ref_geo.bib_areas_types b USING (id_type)
        WHERE
            REPLACE(b.type_code, ' ', '_') = :type_territoire AND
            l.enable = TRUE
        GROUP BY b.type_name
    )
SELECT
    1::INT                        AS gid
  , type_name                     AS nom
  , st_area(st_union) / 10000     AS surf_ha
  , st_area(st_union) / 1000000   AS surf_km2
  , ST_Perimeter(st_union) / 1000 AS perim_km
  , st_transform(st_union, 3857)  AS the_geom
FROM d;

CREATE INDEX index_gist_t_layer_territoire_the_geom
    ON atlas.t_layer_territoire
        USING gist
        (the_geom);

CREATE UNIQUE INDEX t_layer_territoire_gid_idx
    ON atlas.t_layer_territoire
        USING btree(gid);


-- Rafraichissement des vues contenant les données de l'atlas
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_ref_geo()
    RETURNS VOID AS
$$
BEGIN

    REFRESH MATERIALIZED VIEW atlas.t_layer_territoire;
    REFRESH MATERIALIZED VIEW atlas.t_mailles_territoire;
    REFRESH MATERIALIZED VIEW atlas.l_communes;
    REFRESH MATERIALIZED VIEW atlas.vm_communes;

END
$$ LANGUAGE plpgsql;
