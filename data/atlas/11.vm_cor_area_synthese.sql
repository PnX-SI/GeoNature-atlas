-- TODO: should we transfert this query to atlas_gn2.sql ?
IMPORT FOREIGN SCHEMA gn_synthese
    LIMIT TO (gn_synthese.cor_area_synthese)
FROM SERVER geonaturedbserver INTO synthese;

CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
    WITH info_tmp AS (
        SELECT
            sa.id_synthese,
            sa.id_area,
            a.centroid,
            a.id_type,
            s.id_nomenclature_sensitivity,
            st_transform(a.geom, 4326) AS geom
        FROM synthese.synthese AS s
            JOIN synthese.cor_area_synthese AS sa
                ON sa.id_synthese = s.id_synthese
            JOIN ref_geo.l_areas AS a
                ON sa.id_area = a.id_area
            JOIN atlas.t_layer_territoire AS lt
                ON st_intersects(a.geom_4326, lt.geom)
                -- AND NOT ST_Touches(lt.geom, a.geom_4326)
    )
    SELECT
        info.id_synthese,
        info.id_area,
        info.centroid,
        info.geom AS geom,
        st_asgeojson(info.geom) AS geojson_4326,
        st_transform(info.centroid, 4326) AS centroid_4326,
        t.type_code,
        sensi.cd_nomenclature,
        CASE
            WHEN sensi.cd_nomenclature = '1' AND t.type_code = :'sensibility1' THEN true
            WHEN sensi.cd_nomenclature = '2' AND t.type_code = :'sensibility2' THEN true
            WHEN sensi.cd_nomenclature = '3' AND t.type_code = :'sensibility3' THEN true
            WHEN (sensi.cd_nomenclature = '0' OR sensi.cd_nomenclature IS NULL)
                AND t.type_code::text = :'sensibility0'
                THEN true
            ELSE false
        END AS is_blurred_geom
    FROM info_tmp AS info
        JOIN ref_geo.bib_areas_types AS t
            ON info.id_type = t.id_type
        LEFT JOIN synthese.t_nomenclatures AS sensi
            ON info.id_nomenclature_sensitivity = sensi.id_nomenclature
    WHERE t.type_code IN (:'sensibility0', :'sensibility1', :'sensibility2', :'sensibility3')
        AND (NOT sensi.cd_nomenclature = '4'::TEXT OR sensi.cd_nomenclature IS NULL)
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_synthese, id_area);
