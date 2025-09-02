-- Toutes les observations
CREATE MATERIALIZED VIEW atlas.vm_observations AS
    WITH centroid_synthese AS (
        -- donnee non sensibile ou id_nomenclature_sensi = NULL
        SELECT
            s.id_synthese,
            s.the_geom_point as geom_point,
            nom.cd_nomenclature as cd_sensitivity
        FROM synthese.synthese AS s
            LEFT JOIN synthese.t_nomenclatures AS nom
                ON nom.id_nomenclature = s.id_nomenclature_sensitivity
        WHERE nom.cd_nomenclature = '0'
            OR s.id_nomenclature_sensitivity IS NULL

        UNION

        -- données sensible
        SELECT
            DISTINCT ON (s.id_synthese, cor.type_code) -- si l'observation est une ligne ou un polygone elle peut intersecté plusieur fois le même type de zonage
            s.id_synthese,
            st_centroid(st_transform(areas.the_geom, 4326)) AS geom_point,
            tn.cd_nomenclature AS cd_sensitivity
        FROM synthese.synthese AS s
            JOIN atlas.vm_cor_area_synthese AS cor
                ON cor.id_synthese = s.id_synthese
            JOIN ref_geo.bib_areas_types AS bat
                ON bat.type_code = cor.type_code
            JOIN synthese.t_nomenclatures AS tn
                ON tn.id_nomenclature = s.id_nomenclature_sensitivity
            JOIN synthese.cor_sensitivity_area_type AS csat
                ON (
                    csat.id_nomenclature_sensitivity = tn.id_nomenclature
                    AND csat.id_area_type = bat.id_type
                )
            JOIN atlas.vm_l_areas AS areas
                ON cor.id_area = areas.id_area
        WHERE tn.cd_nomenclature != '0'
    )
    SELECT
        c.geom_point AS the_geom_point,
        st_asgeojson(c.geom_point, 4326) AS geojson_point,
        c.cd_sensitivity,
        s.id_synthese AS id_observation,
        s.date_min AS dateobs,
        (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
        s.observers AS observateurs,
        s.id_dataset,
        tx.cd_ref
    FROM synthese.synthese AS s
        JOIN centroid_synthese AS c
            ON c.id_synthese = s.id_synthese
        JOIN atlas.vm_taxref AS tx
            ON tx.cd_nom = s.cd_nom
;

CREATE UNIQUE INDEX ON atlas.vm_observations
    USING btree (id_observation);

CREATE INDEX ON atlas.vm_observations
    USING btree (cd_ref);

CREATE INDEX ON atlas.vm_observations
    USING btree (altitude_retenue);

CREATE INDEX ON atlas.vm_observations
    USING btree (dateobs);

CREATE INDEX ON atlas.vm_observations
    USING gist (the_geom_point);


-- Table des correspondances observations <> zonages;
CREATE MATERIALIZED VIEW atlas.vm_cor_area_observation AS
    SELECT
        cas.id_synthese AS id_observation,
        cas.id_area
    FROM synthese.cor_area_synthese AS cas
        JOIN atlas.vm_l_areas AS la
            ON cas.id_area = la.id_area;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_observation
    USING btree (id_observation, id_area);
