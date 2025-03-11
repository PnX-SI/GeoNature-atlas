--################################
--###
--################################
IMPORT FOREIGN SCHEMA gn_sensitivity
LIMIT TO (cor_sensitivity_area_type)  FROM SERVER geonaturedbserver INTO synthese;

CREATE MATERIALIZED VIEW atlas.vm_bib_areas_types AS
SELECT t.id_type, t.type_code, t.type_name, t.type_desc
FROM ref_geo.bib_areas_types t
WHERE
    type_code IN (SELECT * from string_to_table(:type_code, ','));

CREATE INDEX ON atlas.vm_bib_areas_types(id_type);
CREATE INDEX ON atlas.vm_bib_areas_types(type_code);
CREATE INDEX ON atlas.vm_bib_areas_types(type_name);

-- Suppression de la VM atlas.vm_cor_areas si existe
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_cor_areas CASCADE;

CREATE MATERIALIZED VIEW atlas.vm_cor_areas AS
SELECT ca.id_area_group, ca.id_area
FROM ref_geo.cor_areas ca;

CREATE INDEX ON atlas.vm_cor_areas(id_area_group);
CREATE INDEX ON atlas.vm_cor_areas(id_area);

-- Suppression si temporaire des areas la table existe
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_l_areas;


-- création de la vm l_areas à partir des communes du ref_geo
CREATE MATERIALIZED VIEW atlas.vm_l_areas AS
SELECT
    a.id_area                                AS id_area
     , a.area_code                              AS area_code
     , a.area_name                              AS area_name
     , a.id_type                                AS id_type
     , st_transform(a.geom, 4326)               AS the_geom
     , st_asgeojson(st_transform(a.geom, 4326)) AS area_geojson
     , a.description                            AS description
FROM ref_geo.l_areas a
JOIN ref_geo.bib_areas_types b on a.id_type = b.id_type
    JOIN atlas.t_layer_territoire layer ON ST_INTERSECTS(layer.the_geom, a.geom_4326)
WHERE
    enable = TRUE AND
    b.type_code IN (
        SELECT * from string_to_table(:type_code, ',')
        )
        OR a.id_type in (
            SELECT id_area_type
            FROM synthese.cor_sensitivity_area_type
        )
WITH DATA;

CREATE UNIQUE INDEX vm_l_areas_id_area_idx
    ON atlas.vm_l_areas(id_area);

CREATE INDEX vm_l_areas_the_geom_gidx
    ON atlas.vm_l_areas
        USING gist
        (the_geom);

CREATE INDEX vm_l_areas_area_name_idx
    ON atlas.vm_l_areas(area_code);

--Table des correspondances observations <> zonages;

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_cor_area_observation;

CREATE MATERIALIZED VIEW atlas.vm_cor_area_observation AS
SELECT cas.id_synthese AS id_observation, cas.id_area
FROM
    synthese.cor_area_synthese cas
        JOIN atlas.vm_l_areas la ON cas.id_area = la.id_area;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_observation(id_observation, id_area);

