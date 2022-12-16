-- Compatibility : Atlas v1.5.0+
-- Replace standard SINP blurring with AURA SINP meshes blurring
-- Usage : replace ~/www/atlas/data/gn2/atlas_synthese.sql by this content


CREATE MATERIALIZED VIEW synthese.vm_cor_synthese_area
TABLESPACE pg_default
AS
	SELECT DISTINCT ON (sa.id_synthese, t.type_code)
		sa.id_synthese,
		sa.id_area,
		st_transform(a.centroid, 4326) AS centroid_4326,
		t.type_code,
		a.area_code
	FROM synthese.cor_area_synthese AS sa
		 JOIN ref_geo.l_areas AS a
		 	ON (sa.id_area = a.id_area)
		 JOIN ref_geo.bib_areas_types AS t
		 	ON (a.id_type = t.id_type)
	WHERE t.type_code IN ('M5', 'COM')
WITH DATA;

-- View indexes:
CREATE UNIQUE INDEX ON synthese.vm_cor_synthese_area (id_synthese, id_area);
CREATE INDEX ON synthese.vm_cor_synthese_area (type_code);


VACUUM ANALYSE synthese.vm_cor_synthese_area;


CREATE OR REPLACE FUNCTION atlas.get_blurring_centroid_geom_by_diffusion_level(code CHARACTER VARYING, idSynthese INTEGER)
 RETURNS geometry
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	-- Function which return the centroid for a sensitivity or diffusion_level code and a synthese id
	DECLARE centroid geometry;

	BEGIN
		SELECT INTO centroid csa.centroid_4326
		FROM synthese.vm_cor_synthese_area AS csa
		WHERE csa.id_synthese = idSynthese
			AND csa.type_code = (CASE WHEN code = '0' THEN 'M5' WHEN code = '1' THEN 'M5' WHEN code = '2' THEN 'M5' WHEN code = '3' THEN 'M5' END)
		LIMIT 1 ;

		RETURN centroid ;
	END;
$function$
;

CREATE OR REPLACE FUNCTION atlas.get_blurring_centroid_geom_by_sensitivity(code CHARACTER VARYING, idSynthese INTEGER)
 RETURNS geometry
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	-- Function which return the centroid for a sensitivity or diffusion_level code and a synthese id
	DECLARE centroid geometry;

	BEGIN
		SELECT INTO centroid csa.centroid_4326
		FROM synthese.vm_cor_synthese_area AS csa
		WHERE csa.id_synthese = idSynthese
			AND csa.type_code = (CASE WHEN code = '1' THEN 'M5' WHEN code = '2' THEN 'M5' WHEN code = '3' THEN 'M5' END)
		LIMIT 1 ;

		RETURN centroid ;
	END;
$function$
;

CREATE VIEW synthese.syntheseff AS
SELECT
	s.id_synthese,
	s.id_dataset,
	s.cd_nom,
	s.date_min AS dateobs,
	s.observers AS observateurs,
	(s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
	CASE
		WHEN (sens.cd_nomenclature::INT >= 1 AND sens.cd_nomenclature::INT <= 3 AND dl.cd_nomenclature::INT >= 0 AND dl.cd_nomenclature::INT <= 3) THEN
			CASE
				WHEN (sens.cd_nomenclature::INT >= dl.cd_nomenclature::INT) THEN (
					atlas.get_blurring_centroid_geom_by_sensitivity(sens.cd_nomenclature, s.id_synthese)
				)
				WHEN (sens.cd_nomenclature::INT < dl.cd_nomenclature::INT) THEN (
					atlas.get_blurring_centroid_geom_by_diffusion_level(dl.cd_nomenclature, s.id_synthese)
				)
			END
		WHEN (sens.cd_nomenclature::INT >= 1 AND sens.cd_nomenclature::INT <= 3) AND (dl.cd_nomenclature::INT > 4) THEN (
			atlas.get_blurring_centroid_geom_by_sensitivity(sens.cd_nomenclature, s.id_synthese)
		)
		WHEN (dl.cd_nomenclature::INT >= 0 AND dl.cd_nomenclature::INT <= 3) AND (sens.cd_nomenclature::INT < 1) THEN (
			atlas.get_blurring_centroid_geom_by_diffusion_level(dl.cd_nomenclature, s.id_synthese)
		)
		ELSE st_transform(s.the_geom_point, 4326)
	END AS the_geom_point,
	s.count_min AS effectif_total,
	areas.area_code AS insee,
	sens.cd_nomenclature AS sensitivity,
	dl.cd_nomenclature AS diffusion_level
FROM synthese.synthese s
	JOIN synthese.vm_cor_synthese_area AS areas
		ON (s.id_synthese = areas.id_synthese)
	LEFT JOIN synthese.t_nomenclatures AS sens
		ON (s.id_nomenclature_sensitivity = sens.id_nomenclature)
	LEFT JOIN synthese.t_nomenclatures AS dl
		ON (s.id_nomenclature_diffusion_level = dl.id_nomenclature)
	LEFT JOIN synthese.t_nomenclatures AS st
		ON (s.id_nomenclature_observation_status = st.id_nomenclature)
WHERE areas.type_code = 'COM'
	AND ( NOT dl.cd_nomenclature = '4' OR s.id_nomenclature_diffusion_level IS NULL )
	AND ( NOT sens.cd_nomenclature = '4' OR s.id_nomenclature_sensitivity IS NULL )
	AND st.cd_nomenclature = 'Pr' ;
