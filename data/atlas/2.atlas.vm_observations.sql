-- Fonctions

CREATE OR REPLACE FUNCTION synthese.get_id_nomenclature_type(typeMnemonic varchar)
RETURNS integer
LANGUAGE plpgsql
IMMUTABLE
AS $function$
    -- Function which return the id_type from the mnemonique of a nomenclature type
    DECLARE typeId varchar;
    BEGIN
        SELECT INTO typeId id_type
        FROM synthese.bib_nomenclatures_types
        WHERE mnemonique = typeMnemonic;

        RETURN typeId;
    END;
$function$ ;


CREATE OR REPLACE FUNCTION synthese.get_id_nomenclature(typeMnemonic varchar, nomenclatureCode varchar)
RETURNS integer
LANGUAGE plpgsql
IMMUTABLE
AS $function$
    -- Function which return the id_nomenclature from a mnemonique_type and a cd_nomenclature
    DECLARE nomenclatureId integer;
    BEGIN
        SELECT INTO nomenclatureId id_nomenclature
        FROM synthese.t_nomenclatures AS n
        WHERE n.id_type = synthese.get_id_nomenclature_type(typeMnemonic)
            AND n.cd_nomenclature = nomenclatureCode ;

        RETURN nomenclatureId;
    END;
$function$ ;


CREATE OR REPLACE FUNCTION synthese.get_cd_nomenclature(nomenclatureId int)
RETURNS varchar
LANGUAGE plpgsql
IMMUTABLE
AS $function$
  --Function which return the cd_nomenclature from an id_nomenclature
  DECLARE nomenclatureCode varchar ;
  BEGIN
    SELECT INTO nomenclatureCode cd_nomenclature
    FROM synthese.t_nomenclatures
    WHERE id_nomenclature = nomenclatureId ;

    RETURN nomenclatureCode ;
  END;
$function$ ;


-- Toutes les correspondances observations à flouter et zones géographiques

DROP MATERIALIZED VIEW IF EXISTS atlas.municipality_subdivided ;
CREATE MATERIALIZED VIEW atlas.municipality_subdivided AS
  SELECT
    row_number() OVER() AS gid,
    m.insee,
    m."name",
    m.geom
  FROM (
    SELECT
      a.area_code AS insee,
      a.area_name AS "name",
      st_subdivide(st_transform(a.geom, 4326), 255) AS geom
    FROM ref_geo.l_areas AS a
      JOIN ref_geo.bib_areas_types AS t
        ON t.id_type = a.id_type
    WHERE a."enable" = TRUE
      AND t.type_code = 'COM'
  ) AS m
WITH DATA;

-- View indexes:
CREATE UNIQUE INDEX pk_municipality_subdivided ON atlas.municipality_subdivided USING btree (gid);
CREATE INDEX idx_municipality_subdivided_geom ON atlas.municipality_subdivided USING gist (geom);


CREATE MATERIALIZED VIEW atlas.observations_blurred
TABLESPACE pg_default
AS
  SELECT
    s.id_synthese,
    sat.id_area_type
  FROM synthese.synthese AS s
    JOIN sensitivity.cor_sensitivity_area_type AS sat
      ON s.id_nomenclature_sensitivity = sat.id_nomenclature_sensitivity
  WHERE s.the_geom_point IS NOT NULL
    AND s.id_nomenclature_observation_status = synthese.get_id_nomenclature('STATUT_OBS', 'Pr')
    AND s.id_nomenclature_valid_status IN (
      synthese.get_id_nomenclature('STATUT_VALID', '1'),
      synthese.get_id_nomenclature('STATUT_VALID', '2')
    )
    AND s.id_nomenclature_diffusion_level <> synthese.get_id_nomenclature('NIV_PRECIS', '4')
    AND s.id_nomenclature_sensitivity NOT IN (
      synthese.get_id_nomenclature('SENSIBILITE', '4'),
      synthese.get_id_nomenclature('SENSIBILITE', '2.8')
    )
WITH DATA;

CREATE UNIQUE INDEX pk_observations_blurred ON atlas.observations_blurred USING btree (id_synthese);


CREATE MATERIALIZED VIEW atlas.observations_blurred_geometry
TABLESPACE pg_default
AS
  SELECT
    sa.id_synthese,
    sa.id_area,
    st_transform(a.geom, 4326) AS geom_4326
  FROM synthese.cor_area_synthese AS sa
    JOIN atlas.observations_blurred AS ob
      ON (sa.id_synthese = ob.id_synthese)
    JOIN ref_geo.l_areas AS a
      ON (sa.id_area = a.id_area AND ob.id_area_type = a.id_type)
WITH DATA;

CREATE UNIQUE INDEX i_observations_blurred_geometry ON atlas.observations_blurred_geometry USING btree (id_synthese, id_area);


CREATE MATERIALIZED VIEW atlas.observations_blurred_centroid
TABLESPACE pg_default
AS
    SELECT id_synthese,
        st_centroid(st_union(geom_4326)) AS geom_point
    FROM atlas.observations_blurred_geometry
    GROUP BY id_synthese
WITH DATA;
CREATE UNIQUE INDEX pk_observations_blurred_centroid ON atlas.observations_blurred_centroid USING btree (id_synthese);
CREATE INDEX idx_observations_blurred_centroid ON atlas.observations_blurred_centroid USING gist (geom_point);


CREATE MATERIALIZED VIEW atlas.observations_blurred_insee
TABLESPACE pg_default
AS
    SELECT
        o.id_synthese,
        o.geom_point,
        ms.insee
    FROM atlas.observations_blurred_centroid AS o
        LEFT JOIN atlas.municipality_subdivided AS ms
            ON st_intersects(o.geom_point, ms.geom)
WITH DATA;
CREATE UNIQUE INDEX pk_observations_blurred_insee ON atlas.observations_blurred_insee USING btree (id_synthese);


CREATE MATERIALIZED VIEW atlas.vm_observations
TABLESPACE pg_default
AS
SELECT s.id_synthese AS id_observation,
  COALESCE(bci.insee, (
    SELECT m.insee
    FROM atlas.municipality_subdivided AS m
    WHERE st_intersects(s.the_geom_point, m.geom) = true)
  ) AS insee,
  s.date_min AS dateobs,
  s.observers AS observateurs,
  (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
  CASE
    WHEN bci.geom_point IS NOT NULL THEN bci.geom_point
    ELSE s.the_geom_point
  END AS the_geom_point,
  s.count_min AS effectif_total,
  tx.cd_ref,
  CASE
    WHEN bci.geom_point IS NOT NULL THEN st_asgeojson(bci.geom_point)
    ELSE st_asgeojson(s.the_geom_point)
  END AS geojson_point,
  s.id_dataset
FROM synthese.synthese AS s
  JOIN atlas.vm_taxref AS tx
    ON tx.cd_nom = s.cd_nom
  LEFT JOIN atlas.observations_blurred_insee AS bci
    ON bci.id_synthese = s.id_synthese
WHERE s.the_geom_point IS NOT NULL
    AND s.id_nomenclature_observation_status = synthese.get_id_nomenclature('STATUT_OBS', 'Pr')
    AND s.id_nomenclature_valid_status IN (
      synthese.get_id_nomenclature('STATUT_VALID', '1'),
      synthese.get_id_nomenclature('STATUT_VALID', '2')
    )
    AND s.id_nomenclature_diffusion_level <> synthese.get_id_nomenclature('NIV_PRECIS', '4')
    AND s.id_nomenclature_sensitivity NOT IN (
      synthese.get_id_nomenclature('SENSIBILITE', '4'),
      synthese.get_id_nomenclature('SENSIBILITE', '2.8')
    )
WITH DATA;

-- View indexes:
CREATE INDEX index_gist_vm_observations_the_geom_point ON atlas.vm_observations USING gist (the_geom_point);
CREATE INDEX vm_observations_altitude_retenue_idx ON atlas.vm_observations USING btree (altitude_retenue);
CREATE INDEX vm_observations_cd_ref_idx ON atlas.vm_observations USING btree (cd_ref);
CREATE INDEX vm_observations_dateobs_idx ON atlas.vm_observations USING btree (dateobs);
CREATE UNIQUE INDEX vm_observations_id_observation_idx ON atlas.vm_observations USING btree (id_observation);
CREATE INDEX vm_observations_insee_idx ON atlas.vm_observations USING btree (insee);
