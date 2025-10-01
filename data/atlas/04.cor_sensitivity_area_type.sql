CREATE TABLE atlas.cor_sensitivity_area_type AS
    WITH sensitivity_has_area_type AS (
        SELECT
            '0' AS sensitivity_code,
            :'type_maille' AS area_type_code

        UNION

        SELECT
            n.cd_nomenclature AS sensitivity_code,
            bat.type_code AS area_type_code
        FROM gn_sensitivity.cor_sensitivity_area_type AS sat
            JOIN ref_nomenclatures.t_nomenclatures AS n
                ON n.id_nomenclature = sat.id_nomenclature_sensitivity
            JOIN ref_geo.bib_areas_types AS bat
                ON bat.id_type = sat.id_area_type
    )
    SELECT sensitivity_code, area_type_code
    FROM sensitivity_has_area_type
    ORDER BY sensitivity_code
WITH DATA;

CREATE UNIQUE INDEX ON atlas.cor_sensitivity_area_type
    USING btree (sensitivity_code);

CREATE INDEX ON atlas.cor_sensitivity_area_type
    USING btree (sensitivity_code, area_type_code);
