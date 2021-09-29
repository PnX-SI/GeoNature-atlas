BEGIN;
-- Materialized View: atlas.t_subdivided_territory
CREATE MATERIALIZED VIEW atlas.t_subdivided_territory
TABLESPACE pg_default
AS 
	WITH d AS (
		SELECT st_union(l.geom) AS st_union
		FROM ref_geo.l_areas AS l
			JOIN ref_geo.bib_areas_types AS b USING (id_type)
		WHERE replace(b.type_code::text, ' '::text, '_'::text) = :'type_territoire'
		GROUP BY b.type_name
	)
	SELECT
		random() AS gid,
		1 AS territory_layer_id,
		st_subdivide(st_transform(d.st_union, 4326), 255) AS geom
	FROM d
WITH DATA;

CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_organism
AS SELECT cd_ref, count(*) as nb_observations, id_organism , nom_organism , adresse_organism , cp_organism , ville_organism , tel_organism , email_organism , url_organism ,url_logo
   FROM utilisateurs.bib_organisms bo
     JOIN utilisateurs.cor_dataset_actor cda ON bo.id_organism =cda.id_organism 
     JOIN synthese.synthese s ON s.id_dataset =cda.id_dataset 
     JOIN taxonomie.taxref t on s.cd_nom=t.cd_nom
  group by t.cd_ref, bo.id_organism, bo.nom_organism, bo.adresse_organism, bo.cp_organism, bo.ville_organism, bo.tel_organism, bo.email_organism, bo.url_organism, bo.url_logo
  with data;


-- View indexes:
CREATE INDEX index_gist_t_subdivided_territory_geom ON atlas.t_subdivided_territory USING gist (geom);
CREATE UNIQUE INDEX t_subdivided_territory_gid_idx ON atlas.t_subdivided_territory USING btree (gid);


-- TODO: add content of update_vm_observations.sql here or ask to execute this script in CHANGELOG.


COMMIT;