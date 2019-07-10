drop materialized view atlas.vm_altitudes;
drop materialized view atlas.vm_mois;
drop materialized view atlas.vm_taxons_plus_observes;
drop materialized view atlas.vm_observations_mailles;

drop materialized view atlas.vm_search_taxon;
drop materialized view  atlas.vm_taxons;
drop materialized view atlas.vm_observations;
drop materialized view atlas.vm_taxref;


ALTER TABLE taxonomie.taxref_protection_especes DROP CONSTRAINT taxref_protection_especes_cd_nom_fkey;

-- Vider taxref
DELETE FROM taxonomie.taxref;

DROP view taxonomie.v_taxref_all_listes;
DROP view taxonomie.v_taxref_hierarchie_bibtaxons;


-- Changement lb_nom(100) vers lb_nom(255)
ALTER TABLE taxonomie.taxref ALTER COLUMN lb_auteur TYPE character varying (255);
ALTER TABLE taxonomie.taxref ALTER COLUMN lb_nom TYPE character varying (255);




CREATE OR REPLACE FUNCTION gbif.convert_rank(my_rank text)
  RETURNS text AS
$BODY$
  DECLARE
    the_rank text;

  BEGIN
    IF my_rank = 'KINGDOM' THEN
    the_rank = 'KD';
    ELSIF my_rank = 'PHYLUM' THEN
    the_rank = 'PH';
    ELSIF my_rank = 'CLASS' THEN
    the_rank = 'CL';
    ELSIF my_rank = 'ORDER' THEN
    the_rank = 'OR';
    ELSIF my_rank = 'FAMILY' THEN
    the_rank = 'FM';
    ELSIF my_rank = 'GENUS' THEN
    the_rank = 'GN';
    ELSIF my_rank = 'SPECIES' THEN
    the_rank = 'ES';
    ELSIF my_rank = 'SUBSPECIES' THEN
    the_rank = 'SSES';
    ELSE my_rank = NULL;
    END IF;
    return the_rank;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



-- Remplissage de la table taxref avec les données issues du GBIF (présent dans la table backbone)
INSERT INTO taxonomie.taxref(
            cd_nom, 
            id_statut, 
            id_habitat, 
            id_rang, 
            regne, 
            phylum, 
            classe, 
            ordre, 
            famille, 
            cd_taxsup, 
            cd_sup, 
            cd_ref, 
            lb_nom, 
            lb_auteur, 
            nom_complet, 
            nom_complet_html, 
            nom_valide, 
            nom_vern, 
            nom_vern_eng, 
            group1_inpn, 
            group2_inpn
        )

WITH sup_species AS
     (SELECT id, parent_key FROM gbif.backbone WHERE is_synonym = true LIMIT 100),
k AS
    (SELECT id, scientific_name FROM gbif.backbone
    WHERE rank ='KINGDOM'),
p AS
    (SELECT id, scientific_name FROM gbif.backbone
    WHERE rank ='PHYLUM'),
c AS
    (SELECT id, scientific_name FROM gbif.backbone
    WHERE rank ='CLASS'),
o AS
    (SELECT id, scientific_name FROM gbif.backbone
    WHERE rank ='ORDER'),
f AS
    (SELECT id, scientific_name FROM gbif.backbone
    WHERE rank ='FAMILY')
SELECT
    b.id AS cd_nom,
    '' AS id_statut,
    0 AS id_habitat,
    gbif.convert_rank(rank) AS id_rang,
    k.scientific_name AS regne,
    p.scientific_name AS phylum,
    c.scientific_name AS classe,
    o.scientific_name AS ordre,
    f.scientific_name AS famille,
    CASE WHEN (b.is_synonym = false) THEN b.parent_key		
    WHEN (b.is_synonym = true) THEN NULL 	
    END AS cd_taxsup,
    CASE WHEN (b.is_synonym = false) THEN b.parent_key		
    WHEN (b.is_synonym = true) THEN NULL
    END AS cd_sup,
    CASE WHEN (b.is_synonym = false) THEN b.id
    WHEN (b.is_synonym = true) THEN b.parent_key 
    END AS cd_ref,
    b.scientific_name AS lb_nom,
    b.authorship AS lb_auteur,
    b.canonical_name AS nom_complet,
    b.canonical_name AS nom_complet_html,
    b.scientific_name AS nom_valide,
    b.scientific_name AS nom_vern,
    b.scientific_name AS nom_vern_eng,
    p.scientific_name AS group1_inpn,
    p.scientific_name AS group2_inpn
FROM gbif.backbone AS b
LEFT JOIN k ON k.id = b.kingdom_key
LEFT JOIN p ON p.id = b.phylum_key
LEFT JOIN c ON c.id = b.class_key
LEFT JOIN o ON o.id = b.order_key
LEFT JOIN f ON f.id = b.family_key;



--ajout d'une clé primaire sur gbif.gbifjam sur "taxonKey"
create index on gbif.gbifjam ("taxonKey");

-- insertion des données de la table taxref dans bib_noms (seulement les données ayant des obs)
INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais)
SELECT DISTINCT cd_nom, cd_ref, nom_vern
FROM taxonomie.taxref t
JOIN gbif.gbifjam j ON j."taxonKey" = t.cd_nom
;


---------------------------------------------------------------------
---------------------------------------------------------------------
--------------------------- SYNTHESEFF ------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

--fonction remplacement de la date de la table gbif.gbifjam (car pas au type date à la base)
CREATE OR REPLACE FUNCTION synthese.change_date(my_date character varying(254))
  RETURNS date AS
$BODY$
  DECLARE
    the_date date;

  BEGIN

    the_date = to_date(my_date, 'YYYY-MM-DD');
    return the_date;
    
  EXCEPTION 
    WHEN others 
    THEN
      raise notice 'Error date';
      return null;
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-- Vider la table syntheff
DELETE FROM synthese.syntheseff


-- Changement observateurs(255) vers observateur text
ALTER TABLE synthese.syntheseff ALTER COLUMN observateurs TYPE text;

-- Changement id_synthese serial vers id_synthese bigint pour créer un lien entre gbif.gbifjam.gbifid et id_synthese
ALTER TABLE synthese.syntheseff ALTER COLUMN id_synthese TYPE bigint;

-- insertion des données dans la synthese

INSERT INTO synthese.syntheseff (id_synthese, cd_nom, dateobs, observateurs, the_geom_point, effectif_total, diffusable)
SELECT "gbifID", "taxonKey", synthese.change_date("eventDate"), ' ', ST_transform(ST_SETSRID(ST_MakePoint("decimalLongitude", "decimalLatitude"),4326),3857), 1, 
'True'
FROM gbif.gbifjam
WHERE synthese.change_date("eventDate") IS NOT NULL;



CREATE OR REPLACE FUNCTION atlas.get_all_cd_sup(the_cd_nom integer)
  RETURNS SETOF integer AS
$BODY$
DECLARE rec record;
BEGIN 
for rec in 
   WITH RECURSIVE taxon_sup(cd_nom, lb_nom,  cd_taxsup) AS (
     SELECT cd_nom, lb_nom, cd_taxsup
      FROM taxonomie.taxref WHERE cd_nom = the_cd_nom
     UNION ALL
      SELECT e.cd_nom, e.lb_nom, e.cd_taxsup
       FROM taxon_sup  AS ss, taxonomie.taxref AS e 
       WHERE e.cd_nom = ss.cd_taxsup
)
SELECT cd_nom FROM taxon_sup
LOOP
   RETURN NEXT rec.cd_nom;
END LOOP;
  END;
$BODY$
LANGUAGE plpgsql IMMUTABLE
COST 100;



DROP materialized view atlas.vm_taxref;
-- recréation de la vm_taxref a partir de tous les cd_nom observés + tous les synonymes et leurs parent 
-- pour des questions de perf on ne remet pas tout taxref
CREATE materialized view atlas.vm_taxref AS
WITH observed_taxons AS (
    SELECT DISTINCT atlas.get_all_cd_sup(cd_nom) AS cd_nom FROM synthese.syntheseff) -- 13612 results
SELECT 
    tx.cd_nom,
    tx.id_statut,
    tx.id_habitat,
    tx.id_rang,
    tx.regne,
    tx.phylum,
    tx.classe,
    tx.ordre,
    tx.famille,
    tx.cd_taxsup,
    tx.cd_sup,
    tx.cd_ref,
    tx.lb_nom,
    tx.lb_auteur,
    tx.nom_complet,
    tx.nom_complet_html,
    tx.nom_valide,
    tx.nom_vern,
    tx.nom_vern_eng,
    tx.group1_inpn,
    tx.group2_inpn
FROM taxonomie.taxref tx
   RIGHT JOIN observed_taxons ot ON ot.cd_nom = tx.cd_ref;

CREATE UNIQUE INDEX vm_taxref_cd_nom_idx
  ON atlas.vm_taxref

  USING btree
  (cd_nom);



CREATE INDEX vm_taxref_cd_ref_idx
  ON atlas.vm_taxref
  USING btree
  (cd_ref);

-- Index: atlas.vm_taxref_cd_taxsup_idx

-- DROP INDEX atlas.vm_taxref_cd_taxsup_idx;

CREATE INDEX vm_taxref_cd_taxsup_idx
  ON atlas.vm_taxref
  USING btree
  (cd_taxsup);

-- Index: atlas.vm_taxref_lb_nom_idx

-- DROP INDEX atlas.vm_taxref_lb_nom_idx;

CREATE INDEX vm_taxref_lb_nom_idx
  ON atlas.vm_taxref
  USING btree
  (lb_nom COLLATE pg_catalog."default");

-- Index: atlas.vm_taxref_nom_complet_idx

-- DROP INDEX atlas.vm_taxref_nom_complet_idx;

CREATE INDEX vm_taxref_nom_complet_idx
  ON atlas.vm_taxref
  USING btree
  (nom_complet COLLATE pg_catalog."default");

-- Index: atlas.vm_taxref_nom_valide_idx

-- DROP INDEX atlas.vm_taxref_nom_valide_idx;

CREATE INDEX vm_taxref_nom_valide_idx
  ON atlas.vm_taxref
  USING btree
  (nom_valide COLLATE pg_catalog."default");




CREATE MATERIALIZED VIEW atlas.vm_observations AS 
 SELECT s.id_synthese AS id_observation,
    s.insee,
    s.dateobs,
    s.observateurs,
    s.altitude_retenue,
    s.the_geom_point,
    s.effectif_total,
    tx.cd_ref,
    st_asgeojson(st_transform(st_setsrid(s.the_geom_point, 3857), 4326)) AS geojson_point
   FROM synthese.syntheseff s
     LEFT JOIN atlas.vm_taxref tx ON tx.cd_nom = s.cd_nom
     JOIN atlas.t_layer_territoire m ON ST_Intersects(m.the_geom, s.the_geom_point)
  WHERE s.supprime = false AND s.diffusable = true
WITH DATA;


CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_observation,
    m.id_maille,
    m.the_geom,
    m.geojson_maille
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_intersects(obs.the_geom_point, st_transform(m.the_geom, 3857))
WITH DATA;



REINDEX INDEX atlas.vm_observations_mailles_cd_ref_idx;
REINDEX INDEX atlas.index_gist_atlas_vm_observations_mailles_geom;
REINDEX INDEX atlas.vm_observations_mailles_geojson_maille_idx;
REINDEX INDEX atlas.vm_observations_mailles_id_maille_idx;
REINDEX INDEX atlas.vm_observations_mailles_id_observation_idx;


DROP MATERIALIZED VIEW atlas.vm_search_taxon;
DROP MATERIALIZED VIEW atlas.vm_taxons_plus_observes;
DROP MATERIALIZED VIEW atlas.vm_taxons;
CREATE MATERIALIZED VIEW atlas.vm_taxons AS 
 WITH obs_min_taxons AS (
         SELECT vm_observations.cd_ref,
            min(date_part('year'::text, vm_observations.dateobs)) AS yearmin,
            max(date_part('year'::text, vm_observations.dateobs)) AS yearmax,
            count(vm_observations.id_observation) AS nb_obs
           FROM atlas.vm_observations
          GROUP BY vm_observations.cd_ref
        ), tx_ref AS (
         SELECT tx_1.cd_ref,
            tx_1.regne,
            tx_1.phylum,
            tx_1.classe,
            tx_1.ordre,
            tx_1.famille,
            tx_1.cd_taxsup,
            tx_1.lb_nom,
            tx_1.lb_auteur,
            tx_1.nom_complet,
            tx_1.nom_valide,
            tx_1.nom_vern,
            tx_1.nom_vern_eng,
            tx_1.group1_inpn,
            tx_1.group2_inpn,
            tx_1.nom_complet_html,
            tx_1.id_rang
           FROM atlas.vm_taxref tx_1
          WHERE (tx_1.cd_ref IN ( SELECT obs_min_taxons.cd_ref
                   FROM obs_min_taxons)) AND tx_1.cd_nom = tx_1.cd_ref
        ), my_taxons AS (
         SELECT DISTINCT n.cd_ref,
            pat.valeur_attribut AS patrimonial,
            pr.valeur_attribut AS protection_stricte
           FROM tx_ref n
             LEFT JOIN taxonomie.cor_taxon_attribut pat ON pat.cd_ref = n.cd_ref AND pat.id_attribut = 1
             LEFT JOIN taxonomie.cor_taxon_attribut pr ON pr.cd_ref = n.cd_ref AND pr.id_attribut = 2
          WHERE (n.cd_ref IN ( SELECT obs_min_taxons.cd_ref
                   FROM obs_min_taxons))
        )
 SELECT tx.cd_ref,
    tx.regne,
    tx.phylum,
    tx.classe,
    tx.ordre,
    tx.famille,
    tx.cd_taxsup,
    tx.lb_nom,
    tx.lb_auteur,
    tx.nom_complet,
    tx.nom_valide,
    tx.nom_vern,
    tx.nom_vern_eng,
    tx.group1_inpn,
    tx.group2_inpn,
    tx.nom_complet_html,
    tx.id_rang,
    t.patrimonial,
    t.protection_stricte,
    omt.yearmin,
    omt.yearmax,
    omt.nb_obs
   FROM tx_ref tx
     LEFT JOIN obs_min_taxons omt ON omt.cd_ref = tx.cd_ref
     LEFT JOIN my_taxons t ON t.cd_ref = tx.cd_ref
WITH DATA;

CREATE UNIQUE INDEX vm_taxons_cd_ref_idx
  ON atlas.vm_taxons
  USING btree
  (cd_ref);



CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS 
 SELECT count(*) AS nb_obs,
    obs.cd_ref,
    tax.lb_nom,
    tax.group2_inpn,
    tax.nom_vern,
    m.id_media,
    m.url,
    m.chemin,
    m.id_type
   FROM atlas.vm_observations obs
     JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref
     LEFT JOIN atlas.vm_medias m ON m.cd_ref = obs.cd_ref AND m.id_type = 1
  WHERE date_part('day'::text, obs.dateobs) >= date_part('day'::text, 'now'::text::date - 15) AND date_part('month'::text, obs.dateobs) = date_part('month'::text, 'now'::text::date - 15) OR date_part('day'::text, obs.dateobs) <= date_part('day'::text, 'now'::text::date + 15) AND date_part('month'::text, obs.dateobs) = date_part('day'::text, 'now'::text::date + 15)
  GROUP BY obs.cd_ref, tax.lb_nom, tax.nom_vern, m.url, m.chemin, tax.group2_inpn, m.id_type, m.id_media
  ORDER BY (count(*)) DESC
 LIMIT 12
WITH DATA;


CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx
  ON atlas.vm_taxons_plus_observes
  USING btree
  (cd_ref);



CREATE MATERIALIZED VIEW atlas.vm_search_taxon AS 
 SELECT tx.cd_nom,
    tx.cd_ref,
    COALESCE((tx.lb_nom::text || ' | '::text) || tx.nom_vern::text, tx.lb_nom::text) AS nom_search
   FROM atlas.vm_taxref tx
     JOIN atlas.vm_taxons t ON t.cd_ref = tx.cd_ref
WITH DATA;


CREATE UNIQUE INDEX vm_search_taxon_cd_nom_idx
  ON atlas.vm_search_taxon
  USING btree
  (cd_nom);


CREATE INDEX vm_search_taxon_cd_ref_idx
  ON atlas.vm_search_taxon
  USING btree
  (cd_ref);

-- Index: atlas.vm_search_taxon_nom_search_idx

-- DROP INDEX atlas.vm_search_taxon_nom_search_idx;

CREATE INDEX vm_search_taxon_nom_search_idx
  ON atlas.vm_search_taxon
  USING btree
  (nom_search COLLATE pg_catalog."default");




DROP MATERIALIZED VIEW atlas.vm_mois;
CREATE MATERIALIZED VIEW atlas.vm_mois AS 
 WITH _01 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '1'::double precision
          GROUP BY vm_observations.cd_ref
        ), _02 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '2'::double precision
          GROUP BY vm_observations.cd_ref
        ), _03 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '3'::double precision
          GROUP BY vm_observations.cd_ref
        ), _04 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '4'::double precision
          GROUP BY vm_observations.cd_ref
        ), _05 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '5'::double precision
          GROUP BY vm_observations.cd_ref
        ), _06 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '6'::double precision
          GROUP BY vm_observations.cd_ref
        ), _07 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '7'::double precision
          GROUP BY vm_observations.cd_ref
        ), _08 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '8'::double precision
          GROUP BY vm_observations.cd_ref
        ), _09 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '9'::double precision
          GROUP BY vm_observations.cd_ref
        ), _10 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '10'::double precision
          GROUP BY vm_observations.cd_ref
        ), _11 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '11'::double precision
          GROUP BY vm_observations.cd_ref
        ), _12 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE date_part('month'::text, vm_observations.dateobs) = '12'::double precision
          GROUP BY vm_observations.cd_ref
        )
 SELECT DISTINCT o.cd_ref,
    COALESCE(a.nb::integer, 0) AS _01,
    COALESCE(b.nb::integer, 0) AS _02,
    COALESCE(c.nb::integer, 0) AS _03,
    COALESCE(d.nb::integer, 0) AS _04,
    COALESCE(e.nb::integer, 0) AS _05,
    COALESCE(f.nb::integer, 0) AS _06,
    COALESCE(g.nb::integer, 0) AS _07,
    COALESCE(h.nb::integer, 0) AS _08,
    COALESCE(i.nb::integer, 0) AS _09,
    COALESCE(j.nb::integer, 0) AS _10,
    COALESCE(k.nb::integer, 0) AS _11,
    COALESCE(l.nb::integer, 0) AS _12
   FROM atlas.vm_observations o
     LEFT JOIN _01 a ON a.cd_ref = o.cd_ref
     LEFT JOIN _02 b ON b.cd_ref = o.cd_ref
     LEFT JOIN _03 c ON c.cd_ref = o.cd_ref
     LEFT JOIN _04 d ON d.cd_ref = o.cd_ref
     LEFT JOIN _05 e ON e.cd_ref = o.cd_ref
     LEFT JOIN _06 f ON f.cd_ref = o.cd_ref
     LEFT JOIN _07 g ON g.cd_ref = o.cd_ref
     LEFT JOIN _08 h ON h.cd_ref = o.cd_ref
     LEFT JOIN _09 i ON i.cd_ref = o.cd_ref
     LEFT JOIN _10 j ON j.cd_ref = o.cd_ref
     LEFT JOIN _11 k ON k.cd_ref = o.cd_ref
     LEFT JOIN _12 l ON l.cd_ref = o.cd_ref
  WHERE o.cd_ref IS NOT NULL
  ORDER BY o.cd_ref
WITH DATA;


CREATE UNIQUE INDEX vm_mois_cd_ref_idx
  ON atlas.vm_mois
  USING btree
  (cd_ref);


-- TO CAHNGE WITH CUSTOM ALTITUDE OF THE TERRITORY

CREATE MATERIALIZED VIEW atlas.vm_altitudes AS 
 WITH alt1 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue < 499
          GROUP BY vm_observations.cd_ref
        ), alt2 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 500 AND vm_observations.altitude_retenue <= 999
          GROUP BY vm_observations.cd_ref
        ), alt3 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 1000 AND vm_observations.altitude_retenue <= 1499
          GROUP BY vm_observations.cd_ref
        ), alt4 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 1500 AND vm_observations.altitude_retenue <= 1999
          GROUP BY vm_observations.cd_ref
        ), alt5 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 2000 AND vm_observations.altitude_retenue <= 2499
          GROUP BY vm_observations.cd_ref
        ), alt6 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 2500 AND vm_observations.altitude_retenue <= 2999
          GROUP BY vm_observations.cd_ref
        ), alt7 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 3000 AND vm_observations.altitude_retenue <= 3499
          GROUP BY vm_observations.cd_ref
        ), alt8 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 3500 AND vm_observations.altitude_retenue <= 3999
          GROUP BY vm_observations.cd_ref
        ), alt9 AS (
         SELECT vm_observations.cd_ref,
            count(*) AS nb
           FROM atlas.vm_observations
          WHERE vm_observations.altitude_retenue >= 4000 AND vm_observations.altitude_retenue <= 4102
          GROUP BY vm_observations.cd_ref
        )
 SELECT DISTINCT o.cd_ref,
    COALESCE(a1.nb::integer, 0) AS _0_500,
    COALESCE(a2.nb::integer, 0) AS _500_1000,
    COALESCE(a3.nb::integer, 0) AS _1000_1500,
    COALESCE(a4.nb::integer, 0) AS _1500_2000,
    COALESCE(a5.nb::integer, 0) AS _2000_2500,
    COALESCE(a6.nb::integer, 0) AS _2500_3000,
    COALESCE(a7.nb::integer, 0) AS _3000_3500,
    COALESCE(a8.nb::integer, 0) AS _3500_4000,
    COALESCE(a9.nb::integer, 0) AS _4000_4103
   FROM atlas.vm_observations o
     LEFT JOIN alt1 a1 ON a1.cd_ref = o.cd_ref
     LEFT JOIN alt2 a2 ON a2.cd_ref = o.cd_ref
     LEFT JOIN alt3 a3 ON a3.cd_ref = o.cd_ref
     LEFT JOIN alt4 a4 ON a4.cd_ref = o.cd_ref
     LEFT JOIN alt5 a5 ON a5.cd_ref = o.cd_ref
     LEFT JOIN alt6 a6 ON a6.cd_ref = o.cd_ref
     LEFT JOIN alt7 a7 ON a7.cd_ref = o.cd_ref
     LEFT JOIN alt8 a8 ON a8.cd_ref = o.cd_ref
     LEFT JOIN alt9 a9 ON a9.cd_ref = o.cd_ref
  WHERE o.cd_ref IS NOT NULL
  ORDER BY o.cd_ref
WITH DATA;

REINDEX INDEX atlas.vm_altitudes_cd_ref_idx;



CREATE OR REPLACE FUNCTION atlas.cast_taxonkey(my_taxonkey character varying(254))
  RETURNS integer AS
$BODY$
  DECLARE
    the_taxonkey integer;

  BEGIN

    the_taxonkey = my_taxonkey::integer;
    return the_taxonkey;
    
  EXCEPTION 
    WHEN others 
    THEN
      raise notice 'Error taxonkey';
      return null;
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-- cast insee column to integer (was float)
DROP MATERIALIZED VIEW atlas.vm_communes;

CREATE MATERIALIZED VIEW atlas.vm_communes AS 
 SELECT c.insee::integer,
    c.commune_maj,
    c.the_geom,
    st_asgeojson(st_transform(c.the_geom, 4326)) AS commune_geojson
   FROM atlas.l_communes c
     JOIN atlas.t_layer_territoire t ON st_contains(st_buffer(t.the_geom, 200::double precision), c.the_geom)
WITH DATA;



-- GRANT ALL TABLE
-- replace <MY_PG_READER_USER> with the user you fill in the file settings.ini (variable 'user_pg')

GRANT USAGE ON SCHEMA atlas TO <MY_PG_READER_USER>;

GRANT SELECT ON TABLE atlas.vm_altitudes TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_communes TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_observations TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_cor_taxon_attribut TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_medias TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_observations TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_observations_mailles TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_search_taxon TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_taxons TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_taxons_plus_observes TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_taxref TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_mois TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.vm_altitudes TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.bib_altitudes TO <MY_PG_READER_USER>;
GRANT EXECUTE ON FUNCTION atlas.find_all_taxons_childs(integer) TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.bib_taxref_rangs TO <MY_PG_READER_USER>;
GRANT SELECT ON TABLE atlas.t_mailles_territoire TO <MY_PG_READER_USER>;