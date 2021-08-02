-- Creation d'une vue permettant de reproduire le contenu de la table du même nom dans les versions précédentes

CREATE OR REPLACE VIEW synthese.syntheseff
AS
SELECT d.id_synthese,
   d.cd_nom,
   d.date_min as dateobs,
   d.observers as observateurs,
 	(d.altitude_min + d.altitude_max) / 2 AS altitude_retenue,
   d.the_geom_point,
   d.the_geom_local,
   d.count_min as effectif_total,
   c.insee,
   dl.cd_nomenclature as diffusion_level
   FROM synthese.synthese d
   	   LEFT OUTER JOIN synthese.t_nomenclatures dl ON d.id_nomenclature_diffusion_level = dl.id_nomenclature
   	   LEFT JOIN atlas.l_communes c ON public.st_intersects(st_transform(d.the_geom_point, 3857), c.the_geom);
