-- Creation d'une vue permettant de reproduire le contenu de la table du même nom dans les versions précédentes
CREATE OR REPLACE VIEW synthese.syntheseff
AS WITH areas AS (
         SELECT DISTINCT ON (sa.id_synthese, a.id_area) sa.id_synthese,
            sa.id_area,
            a.centroid,
            st_transform(a.geom, 3857) AS geom,
            st_transform(a.centroid, 3857) AS centroid_3857,
            t.type_code
           FROM synthese.cor_area_synthese sa
             JOIN ref_geo.l_areas a ON sa.id_area = a.id_area
             JOIN ref_geo.bib_areas_types t ON a.id_type = t.id_type
          WHERE t.type_code::text = ANY (ARRAY['M10'::character varying::text, 'M1'::character varying::text, 'COM'::character varying::text, 'DEP'::character varying::text])
        ), obs_data AS (
         SELECT s.id_synthese,
            s.cd_nom,
            s.date_min AS dateobs,
            s.observers AS observateurs,
            (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
                CASE
                    WHEN sensi.cd_nomenclature::text = '1'::text THEN ( SELECT a.geom
                       FROM areas a
                      WHERE a.id_synthese = s.id_synthese AND a.type_code::text = 'M1'::text
                     LIMIT 1)
                    WHEN sensi.cd_nomenclature::text = '2'::text THEN ( SELECT a.geom
                       FROM areas a
                      WHERE a.id_synthese = s.id_synthese AND a.type_code::text = 'M5'::text
                     LIMIT 1)
                    WHEN sensi.cd_nomenclature::text = '3'::text THEN ( SELECT a.geom
                       FROM areas a
                      WHERE a.id_synthese = s.id_synthese AND a.type_code::text = 'M10'::text
                     LIMIT 1)
                    ELSE st_transform(s.the_geom_point, 3857)
                END AS the_geom_point,
            s.count_min AS effectif_total,
            sensi.cd_nomenclature::integer AS sensitivity
           FROM synthese.synthese s
             LEFT JOIN synthese.t_nomenclatures sensi ON s.id_nomenclature_sensitivity = sensi.id_nomenclature
             LEFT JOIN synthese.t_nomenclatures st ON s.id_nomenclature_observation_status = st.id_nomenclature
          WHERE (NOT sensi.cd_nomenclature::text = '4'::text OR s.id_nomenclature_sensitivity IS NULL) AND st.cd_nomenclature::text = 'Pr'::text
        )
 SELECT d.id_synthese,
    d.cd_nom,
    d.dateobs,
    d.observateurs,
    d.altitude_retenue,
    d.the_geom_point,
    d.effectif_total,
    c.insee,
    d.sensitivity
   FROM obs_data d
     LEFT JOIN atlas.l_communes c ON st_within(d.the_geom_point, c.the_geom);
