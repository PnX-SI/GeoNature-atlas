CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
    WITH area_type_codes AS (
        SELECT string_to_table.string_to_table AS area_type_code
        FROM string_to_table(:'type_code', ',')
        UNION
        SELECT area_type_code
        FROM atlas.cor_sensitivity_area_type
    ),
    areas_observations AS (
        -- Areas for sensitive observations.
        -- Only zonages with size higher than sensitivity area type used for the observation.
        SELECT
            csa.id_synthese,
            csa.id_area,
            bat.id_type,
            bat.type_code,
            bat.size_hierarchy
        FROM atlas.vm_observations AS o
            JOIN synthese.cor_area_synthese AS csa
                ON csa.id_synthese = o.id_observation
            JOIN ref_geo.l_areas AS a
                ON a.id_area = csa.id_area
            JOIN ref_geo.bib_areas_types AS bat
                ON bat.id_type = a.id_type
            JOIN atlas.cor_sensitivity_area_type AS csat
                ON csat.sensitivity_code = o.cd_sensitivity
            JOIN ref_geo.bib_areas_types AS bat_se
                ON bat_se.type_code = csat.area_type_code
            JOIN area_type_codes AS atc
                ON atc.area_type_code = bat.type_code
        WHERE (o.cd_sensitivity != '0' OR o.cd_sensitivity IS NOT NULL)
            AND bat.size_hierarchy >= bat_se.size_hierarchy

        UNION

        -- Areas for NO sensitive observations.
        SELECT
            csa.id_synthese,
            csa.id_area,
            bat.id_type,
            bat.type_code,
            bat.size_hierarchy
        FROM atlas.vm_observations AS o
            JOIN synthese.cor_area_synthese AS csa
                ON csa.id_synthese = o.id_observation
            JOIN ref_geo.l_areas AS a
                ON a.id_area = csa.id_area
            JOIN ref_geo.bib_areas_types AS bat
                ON bat.id_type = a.id_type
            JOIN area_type_codes AS atc
                ON atc.area_type_code = bat.type_code
        WHERE (o.cd_sensitivity = '0' AND o.cd_sensitivity IS NULL)
    )
    SELECT
        id_synthese,
        id_area,
        id_type,
        type_code
    FROM areas_observations
    ORDER BY id_synthese, size_hierarchy, type_code
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_synthese, id_area);

CREATE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_area);
