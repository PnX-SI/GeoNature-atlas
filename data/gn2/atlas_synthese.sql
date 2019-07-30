--################################
--  Import FDW
--################################
IMPORT FOREIGN SCHEMA gn_synthese
	LIMIT TO (gn_synthese.synthese, gn_synthese.cor_area_synthese)
    FROM SERVER geonaturedbserver INTO synthese;


IMPORT FOREIGN SCHEMA ref_nomenclatures
	LIMIT TO (ref_nomenclatures.t_nomenclatures, ref_nomenclatures.bib_nomenclatures_types)
    FROM SERVER geonaturedbserver INTO synthese;


CREATE VIEW synthese.syntheseff AS
WITH areas AS (
	SELECT DISTINCT ON (sa.id_synthese,  t.type_code)
        sa.id_synthese, sa.id_area, a.centroid, st_transform(centroid, 3857) as centroid_3857, t.type_code
	FROM  synthese.cor_area_synthese sa
	JOIN ref_geo.l_areas a
	ON sa.id_area = a.id_area
	JOIN ref_geo.bib_areas_types t
	ON a.id_type = t.id_type
	WHERE type_code IN ('M10', 'COM', 'DEP')
 ),  obs_data AS (
	SELECT s.id_synthese,
	    s.cd_nom,
	    s.date_min AS dateobs,
	    s.observers AS observateurs,
	    (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
	    CASE
		WHEN dl.cd_nomenclature = '1' THEN
			(SELECT centroid_3857 FROM areas a WHERE a.id_synthese = s.id_synthese AND type_code = 'COM' LIMIT 1)

		WHEN dl.cd_nomenclature = '2' THEN
			(SELECT centroid_3857 FROM areas a WHERE a.id_synthese = s.id_synthese AND type_code = 'M10' LIMIT 1)

		WHEN dl.cd_nomenclature = '3' THEN
			(SELECT centroid_3857 FROM areas a WHERE a.id_synthese = s.id_synthese AND type_code = 'DEP' LIMIT 1)

		ELSE st_transform(s.the_geom_point, 3857)
	    END AS the_geom_point,
	    s.count_min AS effectif_total,
	    false AS supprime,
	    true AS diffusable,  dl.cd_nomenclature::int as diffusion_level, cd_nomenclature
	   FROM synthese.synthese s
	   LEFT OUTER JOIN synthese.t_nomenclatures dl ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
	  WHERE (NOT dl.cd_nomenclature = '4'::text OR id_nomenclature_diffusion_level IS NULL)   -- Filtre données non diffusable code "4" ou pas de diffusion spécifiée
)
 SELECT d.id_synthese,
    d.cd_nom,
    d.dateobs,
    d.observateurs,
    d.altitude_retenue,
    d.the_geom_point,
    d.effectif_total,
    d.supprime,
    d.diffusable,
    c.insee,
    diffusion_level
FROM obs_data d
JOIN atlas.l_communes c ON st_intersects(d.the_geom_point, c.the_geom);
