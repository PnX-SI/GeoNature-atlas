CREATE TABLE atlas.cor_sensitivity_area_type AS
    WITH sensitivity_has_area_type AS (
        SELECT
            '0' AS sensitivity_code,
            'M5' AS area_type_code

        UNION

        SELECT
            n.cd_nomenclature AS sensitivity_code,
            bat.type_code AS area_type_code
        FROM synthese.cor_sensitivity_area_type AS sat
            JOIN synthese.t_nomenclatures AS n
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


CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
    WITH distinct_obs AS (
        -- si l'observation est une ligne ou un polygone elle peut intersecté plusieur fois le même type de zonage
        SELECT DISTINCT ON (o.id_observation, cor.type_code)
            o.id_observation,
            o.cd_ref,
            date_part('year', o.dateobs) AS annee,
            cor.id_area as id_maille,
            cor.type_code
        FROM atlas.vm_observations AS o
            LEFT JOIN atlas.vm_cor_area_synthese AS cor
                ON cor.id_synthese = o.id_observation
            JOIN atlas.cor_sensitivity_area_type AS sat
                ON sat.sensitivity_code = o.cd_sensitivity AND sat.area_type_code = cor.type_code
    )
    SELECT
        id_maille,
        type_code,
        count(id_observation) AS nbr,
        array_agg(id_observation) AS id_observations
    FROM distinct_obs
    GROUP BY id_maille, type_code
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations_mailles
    USING btree (id_maille);

CREATE INDEX ON atlas.vm_observations_mailles
    USING gin (id_observations);
