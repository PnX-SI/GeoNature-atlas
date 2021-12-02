--Classes d'altitudes, modifiables selon votre contexte

--DROP TABLE atlas.bib_altitudes;
CREATE TABLE atlas.bib_altitudes
(
  id_altitude integer NOT NULL,
  altitude_min integer NOT NULL,
  altitude_max integer NOT NULL,
  label_altitude character varying(255),
  CONSTRAINT bib_altitudes_pk PRIMARY KEY (id_altitude)
);

INSERT_ALTITUDE
UPDATE atlas.bib_altitudes set label_altitude = '_' || altitude_min || '_' || altitude_max+1;


-- Fonction qui permet de créer la VM contenant le nombre d'observations par classes d'altitude pour chaque taxon

-- DROP FUNCTION atlas.create_vm_altitudes();

CREATE OR REPLACE FUNCTION atlas.create_vm_altitudes()
  RETURNS text AS
$BODY$
  DECLARE
    monsql text;
    mesaltitudes RECORD;

  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS atlas.vm_altitudes;

    monsql = 'CREATE materialized view atlas.vm_altitudes AS WITH ';

    FOR mesaltitudes IN SELECT * FROM atlas.bib_altitudes ORDER BY id_altitude LOOP
      IF mesaltitudes.id_altitude = 1 THEN
        monsql = monsql || 'alt' || mesaltitudes.id_altitude ||' AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE altitude_retenue <' || mesaltitudes.altitude_max || ' GROUP BY cd_ref) ';
      ELSE
        monsql = monsql || ',alt' || mesaltitudes.id_altitude ||' AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE altitude_retenue BETWEEN ' || mesaltitudes.altitude_min || ' AND ' || mesaltitudes.altitude_max || ' GROUP BY cd_ref)';
      END IF;
    END LOOP;

    monsql = monsql || ' SELECT DISTINCT o.cd_ref';

    FOR mesaltitudes IN SELECT * FROM atlas.bib_altitudes LOOP
      monsql = monsql || ',COALESCE(a' ||mesaltitudes.id_altitude || '.nb::integer, 0) as '|| mesaltitudes.label_altitude;
    END LOOP;

    monsql = monsql || ' FROM atlas.vm_observations o';

    FOR mesaltitudes IN SELECT * FROM atlas.bib_altitudes LOOP
      monsql = monsql || ' LEFT JOIN alt' || mesaltitudes.id_altitude ||' a' || mesaltitudes.id_altitude || ' ON a' || mesaltitudes.id_altitude || '.cd_ref = o.cd_ref';
    END LOOP;

    monsql = monsql || ' WHERE o.cd_ref is not null ORDER BY o.cd_ref;';

    EXECUTE monsql;
    create unique index ON atlas.vm_altitudes (cd_ref);

    RETURN monsql;

  END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

select atlas.create_vm_altitudes();