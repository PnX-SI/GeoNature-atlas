-- Création d'une table utilitaire pour ordonner les mailles
CREATE TABLE atlas.mailles_type (
	"size" int4 NOT NULL,
	code varchar NULL,
	CONSTRAINT mailles_type_pkey PRIMARY KEY (size)
);
insert into  atlas.mailles_type (code, size)
VALUES ('M1', 1), ('M5', 5), ('M10', 10);

-- Création d'une table de corespondance entre synthese et aires intersecté
-- avec un booléen pour le ligne qui concerne la géométrie floutée selon la sensibilité

--  id_synthese | type_code | is_blurred_geom 
-- -------------+-----------+-----------------
--       1      | M1        | f
--       1      | M5        | f
--       1      | M10       | t

-- Ici une simplification est faite pour ne pas prendre les géométries des départements et communes
-- qui sont beaucoup trop lourdes à traiter
-- On établit la simplification suivante: 

--  Code niveau difusion | Geom associé 
-- ----------------------+---------------
--  0                    |   Précise
--  1                    |   Maille 1km
--  2                    |   Maille 5km
--  3                    |   Maille 10km
--  4                    |   Pas de diffusion
--  5                    |   Précise

create materialized view atlas.vm_cor_area_synthese as
	select sa.id_synthese, 
          sa.id_area, 
          a.centroid, 
          st_transform(geom, 4326) as geom, 
          st_asgeojson(st_transform(geom, 4326)) as geojson_4326, 
          st_transform(centroid, 4326) as centroid_4326, 
          t.type_code,
          dl.cd_nomenclature,
          case 
           when dl.cd_nomenclature = '1' and type_code = 'M1' then true
           when dl.cd_nomenclature = '2' and type_code = 'M5' then true
           when dl.cd_nomenclature = '3' and type_code = 'M10' then true
           else false
          end as is_blurred_geom
	from synthese.synthese s 
  JOIN synthese.cor_area_synthese sa on sa.id_synthese = s.id_synthese
	JOIN ref_geo.l_areas a ON sa.id_area = a.id_area
	JOIN ref_geo.bib_areas_types t ON a.id_type = t.id_type
	LEFT OUTER JOIN synthese.t_nomenclatures dl ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
	WHERE type_code IN ('M1', 'M5', 'M10') AND not ds.cd_nomenclature = '4'
	;
  --  => 42s



   CREATE MATERIALIZED VIEW atlas.vm_observations AS
    SELECT s.id_synthese AS id_observation,
        c.insee,
        s.date_min as dateobs,
	    (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
        -- on prend la geom originale si il n'y a pas de geom dégradée
        -- sinon la geom dégradée
        CASE 
         WHEN cor.geom IS NULL THEN s.the_geom_4326
         ELSE cor.geom 
        END AS the_geom,
        CASE 
         WHEN cor.geom IS NULL THEN st_asgeojson(s.the_geom_4326)
         ELSE cor.geojson_4326
        END AS geojson_point,
        s.observers AS observateurs,
        tx.cd_ref,
        s.id_dataset
    FROM synthese.synthese s
    LEFT OUTER JOIN atlas.vm_cor_area_synthese cor on s.id_synthese = cor.id_synthese AND cor.is_blurred_geom IS TRUE
    JOIN atlas.vm_taxref tx ON tx.cd_nom = s.cd_nom
    JOIN atlas.l_communes c ON st_intersects(s.the_geom_point, c.the_geom);
;
-- 
    ;    
-- => 1m19 secondes 
-- => test avec rejointure vers cor_area_synthese => 11 secondes !
--   => PB: certain geom intersectes avec plusieurs geom donc ça augmente le nb de donnée 
--   -> tester avec une aggregation car une obs peut bien être sur plusieurs communes !


CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
    SELECT obs.id_observation,
obs.cd_ref,
CASE 
  WHEN blurred_geom.id_synthese IS NOT NULL THEN blurred_geom.id_area
  ELSE cor.id_area 
END as id_area,
CASE 
  WHEN blurred_geom.id_synthese IS NOT NULL THEN blurred_geom.geojson_4326
  ELSE cor.geojson_4326 
END as geojson_4326,
date_part('year', dateobs) as annee
FROM atlas.vm_observations obs
LEFT JOIN (
    SELECT geom, id_synthese, id_area, geojson_4326
    FROM atlas.vm_cor_area_synthese cor
    WHERE is_blurred_geom IS TRUE AND cor.type_code = (
        SELECT code FROM atlas.mailles_type WHERE size >= (
            SELECT size FROM atlas.mailles_type WHERE code = 'M10'
        ) order by size ASC LIMIT 1
    )
) as blurred_geom ON blurred_geom.id_synthese = obs.id_observation
JOIN atlas.vm_cor_area_synthese cor ON cor.id_synthese = obs.id_observation AND cor.type_code = 'M5'
;
=> 4s !


