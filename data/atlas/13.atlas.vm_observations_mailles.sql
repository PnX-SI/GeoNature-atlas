CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
    WITH distinct_obs AS (
        -- si l'observation est une ligne ou un polygone elle peut intersecté plusieur fois le même type de zonage
        SELECT DISTINCT ON (o.id_observation, cas.type_code)
            o.id_observation,
            o.cd_ref,
            date_part('year', o.dateobs) AS annee,
            cas.id_area as id_maille,
            cas.type_code
        FROM atlas.vm_observations AS o
            LEFT JOIN atlas.vm_cor_area_synthese AS cas
                ON cas.id_synthese = o.id_observation
            JOIN atlas.cor_sensitivity_area_type AS csat
                ON (
                    o.cd_sensitivity = csat.sensitivity_code
                    AND cas.type_code = csat.area_type_code
                )
    )
    SELECT
        o.cd_ref,
        o.annee,
        o.id_maille,
        o.type_code,
        COUNT(o.id_observation) AS nbr,
        ARRAY_AGG(o.id_observation) AS id_observations
    FROM distinct_obs AS o
    GROUP BY o.cd_ref, o.annee, o.id_maille, o.type_code
    ORDER BY o.cd_ref, o.annee
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations_mailles
    USING btree (cd_ref, annee, id_maille);

CREATE INDEX ON atlas.vm_observations_mailles
    USING btree (annee);

CREATE INDEX ON atlas.vm_observations_mailles
    USING gin (id_observations);

CREATE INDEX ON atlas.vm_observations_mailles
    USING btree (id_maille, cd_ref);
