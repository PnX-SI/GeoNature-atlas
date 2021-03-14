BEGIN;


ALTER FOREIGN TABLE synthese.synthese DROP COLUMN id_nomenclature_obs_meth;


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
		st_subdivide(st_transform(d.st_union, 3857), 255) AS geom
	FROM d
WITH DATA;

-- View indexes:
CREATE INDEX index_gist_t_subdivided_territory_geom ON atlas.t_subdivided_territory USING gist (geom);
CREATE UNIQUE INDEX t_subdivided_territory_gid_idx ON atlas.t_subdivided_territory USING btree (gid);


-- TODO: add content of update_vm_observations.sql here or ask to execute this script in CHANGELOG.


COMMIT;