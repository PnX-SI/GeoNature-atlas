-------------------------------------
--------------TABLES-----------------
-------------------------------------

CREATE TABLE ref_nomenclatures.bib_nomenclatures_types (
	id_type serial4 NOT NULL,
	mnemonique varchar(255) NULL,
	label_default varchar(255) NOT NULL,
	definition_default text NULL,
	label_fr varchar(255) NOT NULL,
	definition_fr text NULL,
	label_en varchar(255) NULL,
	definition_en text NULL,
	label_es varchar(255) NULL,
	definition_es text NULL,
	label_de varchar(255) NULL,
	definition_de text NULL,
	label_it varchar(255) NULL,
	definition_it text NULL,
	"source" varchar(50) NULL,
	statut varchar(20) NULL,
	meta_create_date timestamp DEFAULT now() NULL,
	meta_update_date timestamp DEFAULT now() NULL,
	CONSTRAINT pk_bib_nomenclatures_types PRIMARY KEY (id_type),
	CONSTRAINT unique_bib_nomenclatures_types_mnemonique UNIQUE (mnemonique)
);

CREATE TABLE ref_nomenclatures.t_nomenclatures (
	id_nomenclature serial4 NOT NULL,
	id_type int4 NOT NULL,
	cd_nomenclature varchar(255) NOT NULL,
	mnemonique varchar(255) NULL,
	label_default varchar(255) NOT NULL,
	definition_default text NULL,
	label_fr varchar(255) NOT NULL,
	definition_fr text NULL,
	label_en varchar(255) NULL,
	definition_en text NULL,
	label_es varchar(255) NULL,
	definition_es text NULL,
	label_de varchar(255) NULL,
	definition_de text NULL,
	label_it varchar(255) NULL,
	definition_it text NULL,
	"source" varchar(50) NULL,
	statut varchar(20) NULL,
	"hierarchy" varchar(255) NULL,
	meta_create_date timestamp DEFAULT now() NULL,
	meta_update_date timestamp NULL,
	active bool DEFAULT true NOT NULL,
	CONSTRAINT pk_t_nomenclatures PRIMARY KEY (id_nomenclature),
	CONSTRAINT unique_id_type_cd_nomenclature UNIQUE (id_type, cd_nomenclature),
	CONSTRAINT fk_t_nomenclatures_id_type FOREIGN KEY (id_type) REFERENCES ref_nomenclatures.bib_nomenclatures_types(id_type) ON UPDATE CASCADE
);

CREATE INDEX index_t_nomenclatures_bib_nomenclatures_types_fkey ON ref_nomenclatures.t_nomenclatures USING btree (id_type);


-- gn_meta.t_datasets definition

-- Drop table

-- DROP TABLE gn_meta.t_datasets;

CREATE TABLE gn_meta.t_datasets (
	id_dataset serial4 NOT NULL,
	dataset_name varchar(255) NOT NULL,
	dataset_desc text NULL,
	CONSTRAINT pk_t_datasets PRIMARY KEY (id_dataset)
);

CREATE TABLE gn_meta.cor_dataset_actor (
	id_cda serial4 NOT NULL,
	id_dataset int4 NOT NULL,
	id_organism int4 NULL,
	CONSTRAINT pk_cor_dataset_actor PRIMARY KEY (id_cda),
	CONSTRAINT fk_cor_dataset_actor_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_dataset_actor_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE
);



CREATE TABLE gn_synthese.synthese (
	id_synthese serial4 NOT NULL,
	id_dataset int4 NULL,
	id_nomenclature_sensitivity int4 NULL,
	id_nomenclature_observation_status int4  NULL,
	cd_nom int4 NULL,
	altitude_min int4 NULL,
	altitude_max int4 NULL,
	the_geom_point public.geometry(point, 4326) NULL,
	the_geom_local public.geometry(point, 2154) NULL,
	date_min timestamp NOT NULL,
	observers varchar(1000) NULL,
	CONSTRAINT pk_synthese PRIMARY KEY (id_synthese),
	CONSTRAINT fk_synthese_id_nomenclature_sensitivity FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE,
	CONSTRAINT fk_synthese_id_nomenclature_observation_status FOREIGN KEY (id_nomenclature_observation_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE,
	CONSTRAINT fk_synthese_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE
);

CREATE TABLE gn_synthese.cor_area_synthese (
	id_synthese int4 NOT NULL,
	id_area int4 NOT NULL,
	CONSTRAINT pk_cor_area_synthese PRIMARY KEY (id_synthese, id_area),
	CONSTRAINT fk_cor_area_synthese_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_cor_area_synthese_id_synthese FOREIGN KEY (id_synthese) REFERENCES gn_synthese.synthese(id_synthese) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX i_cor_area_synthese_id_area ON gn_synthese.cor_area_synthese USING btree (id_area);

CREATE TABLE gn_sensitivity.cor_sensitivity_area_type (
	id_nomenclature_sensitivity int4 NULL,
	id_area_type int4 NULL,
	CONSTRAINT cor_sensitivity_area_type_id_area_type_fkey FOREIGN KEY (id_area_type) REFERENCES ref_geo.bib_areas_types(id_type),
	CONSTRAINT cor_sensitivity_area_type_id_nomenclature_sensitivity_fkey FOREIGN KEY (id_nomenclature_sensitivity) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature)
);
-----------------------------------
---------------TRIGGERS-------------
------------------------------------

CREATE OR REPLACE FUNCTION gn_synthese.fct_trig_insert_in_cor_area_synthese_on_each_statement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
      DECLARE
      BEGIN
      -- Intersection avec toutes les areas et écriture dans cor_area_synthese
          INSERT INTO gn_synthese.cor_area_synthese 
            SELECT
              updated_rows.id_synthese AS id_synthese,
              a.id_area AS id_area
            FROM NEW as updated_rows
            JOIN ref_geo.l_areas a
              ON public.ST_INTERSECTS(updated_rows.the_geom_local, a.geom)  
            WHERE a.enable IS TRUE AND (ST_GeometryType(updated_rows.the_geom_local) = 'ST_Point' OR NOT public.ST_TOUCHES(updated_rows.the_geom_local,a.geom));
      RETURN NULL;
      END;
      $function$
;



CREATE OR REPLACE FUNCTION gn_synthese.fct_trig_update_in_cor_area_synthese()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
      DECLARE
      geom_change boolean;
      BEGIN
      DELETE FROM gn_synthese.cor_area_synthese WHERE id_synthese = NEW.id_synthese;

      -- Intersection avec toutes les areas et écriture dans cor_area_synthese
        INSERT INTO gn_synthese.cor_area_synthese SELECT
          s.id_synthese AS id_synthese,
          a.id_area AS id_area
          FROM ref_geo.l_areas a
          JOIN gn_synthese.synthese s
            ON public.ST_INTERSECTS(s.the_geom_local, a.geom)
          WHERE a.enable IS TRUE AND s.id_synthese = NEW.id_synthese AND (ST_GeometryType(NEW.the_geom_local) = 'ST_Point' OR NOT public.ST_TOUCHES(NEW.the_geom_local,a.geom));
      RETURN NULL;
      END;
      $function$
;


create trigger tri_insert_cor_area_synthese 
after insert on gn_synthese.synthese 
referencing new table as new 
for each statement 
execute function gn_synthese.fct_trig_insert_in_cor_area_synthese_on_each_statement()
;


create trigger tri_update_cor_area_synthese after
update
of the_geom_local on
gn_synthese.synthese for each row execute function gn_synthese.fct_trig_update_in_cor_area_synthese();

-------------------------
---------DATA------------
-------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique,label_default,definition_default,label_fr,definition_fr,label_en,definition_en,label_es,definition_es,label_de,definition_de,label_it,definition_it,"source",statut,meta_create_date,meta_update_date) VALUES
	 ('SENSIBILITE','Niveaux de sensibilité','Nomenclature des niveaux de sensibilité possibles','Niveaux de sensibilité','Nomenclature des niveaux de sensibilité possibles',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'SINP','Validé','2019-10-21 11:52:36.169348','2019-10-21 11:52:36.17918'),
	 ('STATUT_OBS','Statut d''observation','Nomenclature des statuts d''observation.','Statut d''observation','Nomenclature des statuts d''observation.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'SINP','Validé','2019-10-21 11:52:36.169348','2019-10-21 11:52:36.17918')
;


INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, label_fr, definition_fr, source, statut, hierarchy, meta_create_date, meta_update_date, active) VALUES
((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'SENSIBILITE'), '0', '0', 'Non sensible - Diffusion précise', 'Non sensible - Diffusion précise', 'Donnée non sensible - Diffusion précise', 'SINP', 'Validé', '016.000', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'SENSIBILITE'), '1', '1', 'Sensible - Diffusion à la Commune ou Znieff', 'Sensible - Diffusion à la Commune ou Znieff', 'Sensible - Commune ou Znieff (visible uniquement à partir du niveau)', 'SINP', 'Validé', '016.001', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'SENSIBILITE'), '2', '2', 'Sensible - Diffusion à la maille 10km', 'Sensible - Diffusion à la maille 10km', 'Sensibile - Mailles 10 (visible uniquement à partir du niveau)', 'SINP', 'Validé', '016.002', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'SENSIBILITE'), '3', '3', 'Sensible - Diffusion au département', 'Sensible - Diffusion au département', 'Sensible - Départements (visible uniquement à partir du niveau)', 'SINP', 'Validé', '016.003', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'SENSIBILITE'), '4', '4', 'Sensible - Aucune diffusion', 'Sensible - Aucune diffusion', 'Sensible - Aucune diffusion', 'SINP', 'Validé', '016.004', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'STATUT_OBS'), 'No', 'No', 'Non observé', 'Non observé', 'Non Observé : L''observateur n''a pas détecté un taxon particulier, recherché suivant le protocole adéquat à la localisation et à la date de l''observation. Le taxon peut être présent et non vu, temporairement absent, ou réellement absent.', 'SINP', 'Validé', '018.001', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'STATUT_OBS'), 'Pr', 'Pr', 'Présent', 'Présent', 'Présent : Un ou plusieurs individus du taxon ont été effectivement observés et/ou des indices témoignant de la présence du taxon', 'SINP', 'Validé', '018.002', '2018-07-04 16:41:12.551179', '2018-07-04 16:41:12.594534', true)
,((SELECT id_type FROM ref_nomenclatures.bib_nomenclatures_types WHERE mnemonique = 'STATUT_OBS'), 'NSP', 'NSP', 'Ne Sait Pas', 'Ne Sait Pas', 'Ne Sait Pas : l''information n''est pas connue', 'SINP', 'Validé', '018.003', '2020-12-22 00:00:00', '2020-12-22 00:00:00', true)
;

INSERT INTO gn_sensitivity.cor_sensitivity_area_type (id_nomenclature_sensitivity, id_area_type) 
SELECT nom.id_nomenclature, bib_r.id_type
FROM (
    VALUES
	 ('0','M1'),
	 ('1','COM'),
	 ('2','M10'),
	 ('3','DEP')
) AS d (cd_sensitivity, type_code)
JOIN ref_nomenclatures.t_nomenclatures nom ON nom.cd_nomenclature = d.cd_sensitivity 
JOIN ref_nomenclatures.bib_nomenclatures_types bib on bib.id_type = nom.id_type 
JOIN ref_geo.bib_areas_types bib_r ON bib_r.type_code = d.type_code
WHERE bib.mnemonique = 'SENSIBILITE';


INSERT INTO gn_meta.t_datasets (id_dataset, dataset_name, dataset_desc) VALUES
(1, 'Observations faune 2024', 'Jeu de données regroupant les observations de faune sauvage réalisées en 2024 dans le cadre du suivi naturaliste.');

WITH nomenclatures AS (
    SELECT 
        t.id_nomenclature,
        t.cd_nomenclature,
        nt.mnemonique as type_mnemonique
    FROM ref_nomenclatures.t_nomenclatures t
    JOIN ref_nomenclatures.bib_nomenclatures_types nt ON t.id_type = nt.id_type
	WHERE nt.mnemonique IN ('SENSIBILITE', 'STATUT_OBS')
)
INSERT INTO gn_synthese.synthese (
    id_dataset, 
    id_nomenclature_sensitivity, 
    id_nomenclature_observation_status, 
    cd_nom, 
    altitude_min, 
    altitude_max, 
    the_geom_point, 
    the_geom_local, 
    date_min, 
    observers
) VALUES
-- Observation 1 : Cerf élaphe, non sensible
(
    (select id_dataset FROM gn_meta.t_datasets WHERE dataset_name = 'Observations faune 2024'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'SENSIBILITE' AND cd_nomenclature = '0'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'STATUT_OBS' AND cd_nomenclature = 'Pr'),
    61000,
    450,
    480,
    ST_SetSRID(ST_MakePoint(6.8629, 45.9237), 4326),
    st_transform(ST_SetSRID(ST_MakePoint(6.8629, 45.9237), 4326), 2154),
    '2024-11-15 08:30:00',
    'Jean Dupont, Marie Martin'
),
-- Observation : sonneur, non sensible
(
    (select id_dataset FROM gn_meta.t_datasets WHERE dataset_name = 'Observations faune 2024'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'SENSIBILITE' AND cd_nomenclature = '0'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'STATUT_OBS' AND cd_nomenclature = 'Pr'),
    212,
    1200,
    1250,
    ST_SetSRID(ST_MakePoint(6.7234, 45.8901), 4326),
    st_transform(ST_SetSRID(ST_MakePoint(6.7234, 45.8901), 4326), 2154),
    '2024-10-22 14:15:00',
    'Pierre le Lynx'
),
-- Observation 3 : Aigle royal, sensible - maille 10km
(
    (select id_dataset FROM gn_meta.t_datasets WHERE dataset_name = 'Observations faune 2024'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'SENSIBILITE' AND cd_nomenclature = '2'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'STATUT_OBS' AND cd_nomenclature = 'Pr'),
    2645,
    1800,
    1850,
    ST_SetSRID(ST_MakePoint(6.317139, 44.922029), 4326),
    st_transform(ST_SetSRID(ST_MakePoint(6.317139, 44.922029), 4326), 2154),
    '2024-09-05 11:45:00',
    'Sophie'
),
-- Observation 4 : Loup gris, sensible - diffusion département
(
    (select id_dataset FROM gn_meta.t_datasets WHERE dataset_name = 'Observations faune 2024'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'SENSIBILITE' AND cd_nomenclature = '3'),
    (SELECT id_nomenclature FROM nomenclatures WHERE type_mnemonique = 'STATUT_OBS' AND cd_nomenclature = 'Pr'),
    60577,
    980,
    1020,
    ST_SetSRID(ST_MakePoint(6.328125, 44.774036), 4326),
    st_transform(ST_SetSRID(ST_MakePoint(6.328125, 44.774036), 4326), 2154),
    '2024-12-01 16:30:00',
    'John'
);