-- Vue contenant les zonages de chaque observations, 
-- en y ajoutant une colonne "is_valid_for_display" indiquant, pour les données sensibles,
-- si leur niveau de floutage est supérieur à la taille du type de zonage 
-- (dans ce cas on ne l'affiche pas sur les fiches de ce type de zonage)

CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
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
FROM gn_synthese.cor_area_synthese AS cas
    JOIN ref_geo.l_areas AS a
        ON cas.id_area = a.id_area
    JOIN ref_geo.bib_areas_types AS bat
        ON a.id_type = bat.id_type
    JOIN atlas.vm_observations AS s
        ON cas.id_synthese = s.id_observation
    JOIN atlas.vm_cor_sensitivity_area_type AS csat
        ON s.cd_sensitivity = csat.sensitivity_code
    JOIN ref_geo.bib_areas_types AS bat_flou
        ON csat.area_type_code = bat_flou.type_code ;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_synthese, id_area);

CREATE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_area, id_synthese);

CREATE INDEX idx_vm_cor_area_synthese_valid_covering
    ON atlas.vm_cor_area_synthese USING btree (id_synthese)
    INCLUDE (id_area)
    WHERE is_valid_for_display IS TRUE;

-- Force analyse to use indexes with other materialized views during installation
ANALYZE atlas.vm_cor_area_synthese;
