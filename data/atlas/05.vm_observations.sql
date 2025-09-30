-- All the observations to use in the Atlas
CREATE MATERIALIZED VIEW atlas.vm_observations AS
    WITH centroids AS (
        -- Unsensitive data or id_nomenclature_sensitivity = NULL
        SELECT
            s.id_synthese,
            se.cd_nomenclature AS cd_sensitivity,
            s.the_geom_point AS geom_point
        FROM synthese.synthese AS s
            LEFT JOIN synthese.t_nomenclatures AS se
                ON se.id_nomenclature = s.id_nomenclature_sensitivity
            LEFT JOIN synthese.t_nomenclatures AS st
                ON s.id_nomenclature_observation_status = st.id_nomenclature
        WHERE s.the_geom_point IS NOT NULL
            AND (st.cd_nomenclature = 'Pr' OR s.id_nomenclature_observation_status IS NULL)
            AND (se.cd_nomenclature = '0' OR s.id_nomenclature_sensitivity IS NULL)

        UNION

        -- Sensitive data
        SELECT
            s.id_synthese,
            se.cd_nomenclature AS cd_sensitivity,
            st_centroid(st_union(a.the_geom)) AS geom_point
        FROM synthese.synthese AS s
            LEFT JOIN synthese.t_nomenclatures AS st
                ON s.id_nomenclature_observation_status = st.id_nomenclature
            JOIN synthese.cor_area_synthese AS cas
                ON cas.id_synthese = s.id_synthese
            JOIN atlas.vm_l_areas AS a
                ON a.id_area = cas.id_area
            JOIN ref_geo.bib_areas_types AS bat
                ON bat.id_type = a.id_type
            JOIN synthese.t_nomenclatures AS se
                ON se.id_nomenclature = s.id_nomenclature_sensitivity
            JOIN synthese.cor_sensitivity_area_type AS csat
                ON (
                    csat.id_nomenclature_sensitivity = se.id_nomenclature
                    AND csat.id_area_type = bat.id_type
                )
        WHERE s.the_geom_point IS NOT NULL
            AND (st.cd_nomenclature = 'Pr' OR s.id_nomenclature_observation_status IS NULL)
            AND se.cd_nomenclature NOT IN ('0', '4', '2.8')
        GROUP BY s.id_synthese, se.cd_nomenclature
    )
    SELECT
        s.id_synthese AS id_observation,
        c.geom_point AS the_geom_point,
        st_asgeojson(c.geom_point) AS geojson_point,
        c.cd_sensitivity,
        s.date_min AS dateobs,
        (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
        s.observers AS observateurs,
        s.id_dataset,
        tx.cd_ref
    FROM synthese.synthese AS s
        JOIN centroids AS c
            ON c.id_synthese = s.id_synthese
        JOIN atlas.vm_taxref AS tx
            ON tx.cd_nom = s.cd_nom
    ORDER BY s.id_synthese
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations
    USING btree (id_observation);

CREATE INDEX ON atlas.vm_observations
    USING btree (cd_ref);

CREATE INDEX ON atlas.vm_observations
    USING btree (altitude_retenue);

CREATE INDEX ON atlas.vm_observations
    USING btree (dateobs);

CREATE INDEX ON atlas.vm_observations
    USING btree (cd_sensitivity);

CREATE INDEX ON atlas.vm_observations
    USING gist (the_geom_point);
