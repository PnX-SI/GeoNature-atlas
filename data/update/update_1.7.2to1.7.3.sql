-- Creation d'une vue permettant de reproduire le contenu de la table du même nom dans les versions précédentes

CREATE OR REPLACE VIEW synthese.syntheseff AS
WITH areas
    AS (SELECT DISTINCT ON (sa.id_synthese, t.type_code) sa.id_synthese
                                                       , sa.id_area
                                                       , a.centroid
                                                       , st_transform(a.centroid, 4326) AS centroid_4326
                                                       , t.type_code
        FROM ref_geo.bib_areas_types t
                 JOIN ref_geo.l_areas a ON t.id_type = a.id_type
                 JOIN synthese.cor_area_synthese sa ON sa.id_area = a.id_area
        WHERE t.type_code::TEXT = ANY
              (ARRAY ['M10'::CHARACTER VARYING, 'COM'::CHARACTER VARYING, 'DEP'::CHARACTER VARYING]::TEXT[]))
   , obs_data AS (SELECT s.id_synthese
                       , s.cd_nom
                       , s.id_dataset
                       , s.date_min                                                          AS dateobs
                       , s.observers                                                         AS observateurs
                       , (s.altitude_min + s.altitude_max) / 2                               AS altitude_retenue
                       , COALESCE(areas.centroid_4326, st_transform(s.the_geom_point, 4326)) AS the_geom_point
                       , s.count_min                                                         AS effectif_total
                       , dl.cd_nomenclature::INTEGER                                         AS diffusion_level
                  FROM synthese.synthese s
                           LEFT JOIN synthese.t_nomenclatures dl
                                     ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
                           LEFT JOIN synthese.t_nomenclatures st
                                     ON s.id_nomenclature_observation_status = st.id_nomenclature
                           LEFT JOIN areas ON (
                      s.id_synthese = areas.id_synthese
                          AND areas.type_code = CASE
                                                    WHEN dl.cd_nomenclature::TEXT = '1'::TEXT
                                                        THEN 'COM'
                                                    WHEN dl.cd_nomenclature::TEXT = '2'::TEXT
                                                        THEN 'M10'
                                                    WHEN dl.cd_nomenclature::TEXT = '3'::TEXT
                                                        THEN 'DEP'
                          END)
                  WHERE (NOT dl.cd_nomenclature::TEXT = '4'::TEXT
                      OR s.id_nomenclature_diffusion_level IS NULL)
                    AND st.cd_nomenclature::TEXT = 'Pr'::TEXT)
SELECT d.id_synthese
     , d.id_dataset
     , d.cd_nom
     , d.dateobs
     , d.observateurs
     , d.altitude_retenue
     , d.the_geom_point
     , d.effectif_total
     , c.insee
     , diffusion_level
FROM obs_data d
         JOIN atlas.l_communes c ON st_intersects(d.the_geom_point, c.the_geom);
