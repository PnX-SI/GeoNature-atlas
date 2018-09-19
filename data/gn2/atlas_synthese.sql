--################################
--  Import FDW
--################################
IMPORT FOREIGN SCHEMA gn_synthese
	LIMIT TO (gn_synthese.synthese)
    FROM SERVER geonaturedbserver INTO synthese;


IMPORT FOREIGN SCHEMA ref_nomenclatures
	LIMIT TO (ref_nomenclatures.t_nomenclatures, ref_nomenclatures.bib_nomenclatures_types)
    FROM SERVER geonaturedbserver INTO synthese;


CREATE VIEW synthese.syntheseff AS
WITH obs_data AS (
	SELECT
	    s.id_synthese as id_synthese,
	    s.cd_nom as cd_nom,
	    s.date_min as dateobs,
	    s.observers as observateurs,
	    (s.altitude_min + s.altitude_max)/2 as altitude_retenue,
	    st_transform(the_geom_point, 3857) as the_geom_point,
	    s.count_min as effectif_total,
	    false as supprime,
	    True AS diffusable
	FROM synthese.synthese s
	JOIN synthese.t_nomenclatures dl ON id_nomenclature_diffusion_level = dl.id_nomenclature
	WHERE NOT dl.cd_nomenclature = '4'
		AND NOT last_action='D'
)
SELECT
	d.id_synthese, d.cd_nom, d.dateobs, d.observateurs,
	d.altitude_retenue, d.the_geom_point, d.effectif_total,
	d.supprime, d.diffusable,
	c.insee as insee
FROM obs_data d
JOIN atlas.l_communes c
ON st_intersects(d.the_geom_point, c.the_geom);

ALTER TABLE synthese.syntheseff OWNER TO myuser;
GRANT ALL ON TABLE synthese.syntheseff TO myuser;
