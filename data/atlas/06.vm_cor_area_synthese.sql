CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese as
SELECT 
    cas.id_synthese,
    cas.id_area,
    bat.id_type,
    bat.type_code,
    CASE
        -- Si l'observation n'est pas sensible, tous les zonages sont valides
        WHEN (s.cd_sensitivity = '0' OR s.cd_sensitivity IS NULL) THEN TRUE
        -- Si l'observation est sensible, vérifier que le zonage est assez grand par rapport à son niveau de floutage
        WHEN ((s.cd_sensitivity != '0' AND s.cd_sensitivity IS NOT NULL) 
              AND bat.size_hierarchy >= bat_flou.size_hierarchy) THEN TRUE
        ELSE FALSE
    END AS is_valid_for_display
FROM gn_synthese.cor_area_synthese cas
JOIN ref_geo.l_areas a ON cas.id_area = a.id_area
JOIN ref_geo.bib_areas_types bat ON a.id_type = bat.id_type
JOIN atlas.vm_observations s ON cas.id_synthese = s.id_observation
JOIN atlas.cor_sensitivity_area_type csat ON s.cd_sensitivity = csat.sensitivity_code
JOIN ref_geo.bib_areas_types bat_flou ON csat.area_type_code = bat_flou.type_code
;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_synthese, id_area);

CREATE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_area);