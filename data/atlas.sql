--VUES MATERIALISEES--

--Copie du contenu de taxref (à partir du schéma taxonomie de TaxHub)

--DROP materialized view taxonomie.vm_taxref;
CREATE materialized view atlas.vm_taxref AS
SELECT * FROM taxonomie.taxref;

CREATE UNIQUE INDEX ON atlas.vm_taxref (cd_nom);
CREATE INDEX ON atlas.vm_taxref (cd_ref);
CREATE INDEX ON atlas.vm_taxref (cd_taxsup);
CREATE INDEX ON atlas.vm_taxref (lb_nom);
CREATE INDEX ON atlas.vm_taxref (nom_complet);
CREATE INDEX ON atlas.vm_taxref (nom_valide);


--Toutes les observations

-- Materialized View: atlas.vm_observations
--DROP materialized view atlas.vm_observations;
 CREATE MATERIALIZED VIEW atlas.vm_observations AS
	SELECT s.id_synthese AS id_observation,
		s.insee,
		s.dateobs,
		s.observateurs,
		s.altitude_retenue,
		s.the_geom_point AS the_geom_point,
		s.effectif_total,
		tx.cd_ref,
		st_asgeojson(s.the_geom_point) AS geojson_point,
		s.diffusion_level
	FROM synthese.syntheseff AS s
		LEFT JOIN atlas.vm_taxref AS tx ON tx.cd_nom = s.cd_nom
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations (id_observation);
CREATE INDEX ON atlas.vm_observations (cd_ref);
CREATE INDEX ON atlas.vm_observations (insee);
CREATE INDEX ON atlas.vm_observations (altitude_retenue);
CREATE INDEX ON atlas.vm_observations (dateobs);
CREATE INDEX index_gist_vm_observations_the_geom_point ON atlas.vm_observations USING gist (the_geom_point);


--Tous les taxons ayant au moins une observation

--DROP MATERIALIZED VIEW atlas.vm_taxons;
CREATE MATERIALIZED VIEW atlas.vm_taxons AS
 WITH obs_min_taxons AS (
         SELECT vm_observations.cd_ref,
            min(date_part('year'::text, vm_observations.dateobs)) AS yearmin,
            max(date_part('year'::text, vm_observations.dateobs)) AS yearmax,
            COUNT(vm_observations.id_observation) AS nb_obs
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
            pr.valeur_attribut  AS protection_stricte
           FROM tx_ref n
             LEFT JOIN taxonomie.cor_taxon_attribut pat ON pat.cd_ref = n.cd_ref AND pat.id_attribut = 1
             LEFT JOIN taxonomie.cor_taxon_attribut pr ON pr.cd_ref = n.cd_ref AND pr.id_attribut = 2
          WHERE n.cd_ref IN ( SELECT obs_min_taxons.cd_ref
                   FROM obs_min_taxons)
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
CREATE UNIQUE INDEX ON atlas.vm_taxons (cd_ref);

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


-- Taxons observés et de tous leurs synonymes (utilisés pour la recherche d'une espèce)

CREATE MATERIALIZED VIEW atlas.vm_search_taxon AS 
SELECT row_number() OVER (ORDER BY t.cd_nom,t.cd_ref,t.search_name)::integer AS fid,
  t.cd_nom,
  t.cd_ref,
  t.search_name,
  t.nom_valide,
  t.lb_nom
FROM (
  SELECT t_1.cd_nom,
        t_1.cd_ref,
        concat(t_1.lb_nom, ' =  <i> ', t_1.nom_valide, '</i>') AS search_name,
        t_1.nom_valide,
        t_1.lb_nom
  FROM atlas.vm_taxref t_1

  UNION
  SELECT t_1.cd_nom,
        t_1.cd_ref,
        concat(t_1.nom_vern, ' =  <i> ', t_1.nom_valide, '</i>' ) AS search_name,
        t_1.nom_valide,
        t_1.lb_nom
  FROM atlas.vm_taxref t_1
  WHERE t_1.nom_vern IS NOT NULL AND t_1.cd_nom = t_1.cd_ref
) t
JOIN atlas.vm_taxons taxons ON taxons.cd_ref = t.cd_ref;

CREATE UNIQUE INDEX ON atlas.vm_search_taxon(fid);
CREATE INDEX ON atlas.vm_search_taxon(cd_nom);
create INDEX ON atlas.vm_search_taxon(cd_ref);

CREATE INDEX trgm_idx ON atlas.vm_search_taxon USING GIST (search_name gist_trgm_ops);
CREATE UNIQUE INDEX ON atlas.vm_search_taxon (cd_nom, search_name);

-- Nombre d'observations mensuelles pour chaque taxon observé

CREATE materialized view atlas.vm_mois AS
WITH
_01 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '01' GROUP BY cd_ref),
_02 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '02' GROUP BY cd_ref),
_03 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '03' GROUP BY cd_ref),
_04 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '04' GROUP BY cd_ref),
_05 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '05' GROUP BY cd_ref),
_06 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '06' GROUP BY cd_ref),
_07 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '07' GROUP BY cd_ref),
_08 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '08' GROUP BY cd_ref),
_09 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '09' GROUP BY cd_ref),
_10 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '10' GROUP BY cd_ref),
_11 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '11' GROUP BY cd_ref),
_12 AS (SELECT cd_ref, count(*) as nb FROM atlas.vm_observations WHERE date_part('month'::text, dateobs) = '12' GROUP BY cd_ref)

SELECT DISTINCT o.cd_ref
  ,COALESCE(a.nb::integer, 0) as _01
  ,COALESCE(b.nb::integer, 0) as _02
  ,COALESCE(c.nb::integer, 0) as _03
  ,COALESCE(d.nb::integer, 0) as _04
  ,COALESCE(e.nb::integer, 0) as _05
  ,COALESCE(f.nb::integer, 0) as _06
  ,COALESCE(g.nb::integer, 0) as _07
  ,COALESCE(h.nb::integer, 0) as _08
  ,COALESCE(i.nb::integer, 0) as _09
  ,COALESCE(j.nb::integer, 0) as _10
  ,COALESCE(k.nb::integer, 0) as _11
  ,COALESCE(l.nb::integer, 0) as _12
FROM atlas.vm_observations o
LEFT JOIN _01 a ON a.cd_ref =  o.cd_ref
LEFT JOIN _02 b ON b.cd_ref =  o.cd_ref
LEFT JOIN _03 c ON c.cd_ref =  o.cd_ref
LEFT JOIN _04 d ON d.cd_ref =  o.cd_ref
LEFT JOIN _05 e ON e.cd_ref =  o.cd_ref
LEFT JOIN _06 f ON f.cd_ref =  o.cd_ref
LEFT JOIN _07 g ON g.cd_ref =  o.cd_ref
LEFT JOIN _08 h ON h.cd_ref =  o.cd_ref
LEFT JOIN _09 i ON i.cd_ref =  o.cd_ref
LEFT JOIN _10 j ON j.cd_ref =  o.cd_ref
LEFT JOIN _11 k ON k.cd_ref =  o.cd_ref
LEFT JOIN _12 l ON l.cd_ref =  o.cd_ref
WHERE o.cd_ref is not null
ORDER BY o.cd_ref;
CREATE UNIQUE INDEX ON atlas.vm_mois (cd_ref);


-- Communes contenues entièrement dans le territoire

CREATE MATERIALIZED VIEW atlas.vm_communes AS
SELECT c.insee,
c.commune_maj,
c.the_geom,
st_asgeojson(st_transform(c.the_geom, 4326)) as commune_geojson
FROM atlas.l_communes c
JOIN atlas.t_layer_territoire t ON ST_CONTAINS(ST_BUFFER(t.the_geom,200), c.the_geom);

CREATE UNIQUE INDEX ON atlas.vm_communes (insee);
CREATE INDEX index_gist_vm_communes_the_geom ON atlas.vm_communes USING gist (the_geom);


-- Rangs de taxref ordonnés

CREATE TABLE atlas.bib_taxref_rangs (
    id_rang character(4) NOT NULL,
    nom_rang character varying(20) NOT NULL,
    tri_rang integer
);
INSERT INTO atlas.bib_taxref_rangs (id_rang, nom_rang, tri_rang) VALUES ('Dumm', 'Domaine', 1);
INSERT INTO atlas.bib_taxref_rangs (id_rang, nom_rang, tri_rang) VALUES ('SPRG', 'Super-Règne', 2);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('KD  ', 'Règne', 3);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSRG', 'Sous-Règne', 4);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFRG', 'Infra-Règne', 5);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('PH  ', 'Embranchement', 6);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBPH', 'Sous-Phylum', 7);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFPH', 'Infra-Phylum', 8);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('DV  ', 'Division', 9);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBDV', 'Sous-division', 10);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPCL', 'Super-Classe', 11);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CLAD', 'Cladus', 12);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CL  ', 'Classe', 13);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBCL', 'Sous-Classe', 14);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFCL', 'Infra-classe', 15);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('LEG ', 'Legio', 16);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPOR', 'Super-Ordre', 17);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('COH ', 'Cohorte', 18);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('OR  ', 'Ordre', 19);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBOR', 'Sous-Ordre', 20);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFOR', 'Infra-Ordre', 21);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPFM', 'Super-Famille', 22);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FM  ', 'Famille', 23);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBFM', 'Sous-Famille', 24);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('TR  ', 'Tribu', 26);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSTR', 'Sous-Tribu', 27);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('GN  ', 'Genre', 28);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSGN', 'Sous-Genre', 29);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SC  ', 'Section', 30);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBSC', 'Sous-Section', 31);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SER', 'Série', 32);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSER', 'Sous-Série', 33);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('AGES', 'Agrégat', 34);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('ES  ', 'Espèce', 35);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SMES', 'Semi-espèce', 36);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('MES ', 'Micro-Espèce',37);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSES', 'Sous-espèce', 38);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('NAT ', 'Natio', 39);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('VAR ', 'Variété', 40);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SVAR ', 'Sous-Variété', 41);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FO  ', 'Forme', 42);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSFO', 'Sous-Forme', 43);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FOES', 'Forma species', 44);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('LIN ', 'Linea', 45);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CLO ', 'Clône', 46);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('RACE', 'Race', 47);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CAR ', 'Cultivar', 48);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('MO  ', 'Morpha', 49);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('AB  ', 'Abberatio',50);
--n'existe plus dans taxref V9
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('CVAR', 'Convariété');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('HYB ', 'Hybride');
--non documenté dans la doc taxref
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPTR', 'Supra-Tribu', 25);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('SCO ', '?');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('PVOR', '?');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('SSCO', '?');


-- Médias de chaque taxon

CREATE MATERIALIZED VIEW atlas.vm_medias AS
 SELECT t_medias.id_media,
    t_medias.cd_ref,
    t_medias.titre,
    t_medias.url,
    t_medias.chemin,
    t_medias.auteur,
    t_medias.desc_media,
    t_medias.date_media,
    t_medias.id_type,
    t_medias.licence,
    t_medias.source
   FROM taxonomie.t_medias;
CREATE UNIQUE INDEX ON atlas.vm_medias (id_media);


-- Attributs de chaque taxon (description, commentaire, milieu et chorologie)

CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_attribut AS
    SELECT id_attribut,
           valeur_attribut,
           cd_ref
    FROM taxonomie.cor_taxon_attribut
    WHERE id_attribut IN (100, 101, 102, 103);
CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_attribut (cd_ref,id_attribut);

-- 12 taxons les plus observés sur la période en cours (par défaut -15 jours +15 jours toutes années confondues)

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
LIMIT 12;
-- DROP INDEX atlas.vm_taxons_plus_observes_cd_ref_idx;

CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx
  ON atlas.vm_taxons_plus_observes
  USING btree
  (cd_ref);


--Fonction qui permet de lister tous les taxons enfants d'un taxon

CREATE OR REPLACE FUNCTION atlas.find_all_taxons_childs(id integer)
  RETURNS SETOF integer AS
$BODY$
 --Param : cd_nom ou cd_ref d'un taxon quelque soit son rang
 --Retourne le cd_nom de tous les taxons enfants sous forme d'un jeu de données utilisable comme une table
 --Usage SELECT atlas.find_all_taxons_childs(197047);
 --ou SELECT * FROM atlas.vm_taxons WHERE cd_ref IN(SELECT * FROM atlas.find_all_taxons_childs(197047))
  DECLARE
    inf RECORD;
    c integer;
  BEGIN
    SELECT INTO c count(*) FROM atlas.vm_taxref WHERE cd_taxsup = id;
    IF c > 0 THEN
        FOR inf IN
      WITH RECURSIVE descendants AS (
        SELECT tx1.cd_nom FROM atlas.vm_taxref tx1 WHERE tx1.cd_taxsup = id
      UNION ALL
      SELECT tx2.cd_nom FROM descendants d JOIN atlas.vm_taxref tx2 ON tx2.cd_taxsup = d.cd_nom
      )
      SELECT cd_nom FROM descendants
  LOOP
      RETURN NEXT inf.cd_nom;
  END LOOP;
    END IF;
  END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100
  ROWS 1000;


-------- CRÉATION DU SCHÉMA -------------
CREATE SCHEMA utilisateurs AUTHORIZATION geonatadmin;

-- TABLE bib_organisme
CREATE FOREIGN TABLE utilisateurs.bib_organismes (
    id_organisme int4 OPTIONS(column_name 'id_organisme') NOT NULL,
    uuid_organisme uuid OPTIONS(column_name 'uuid_organisme') NULL,
    nom_organisme varchar(500) OPTIONS(column_name 'nom_organisme') NULL,
    adresse_organisme varchar(128) OPTIONS(column_name 'adresse_organisme') NULL,
    cp_organisme varchar(5) OPTIONS(column_name 'cp_organisme') NULL,
    ville_organisme varchar(50) OPTIONS(column_name 'ville_organisme') NULL,
    tel_organisme varchar(14) OPTIONS(column_name 'tel_organisme') NULL,
    fax_organisme varchar(14) OPTIONS(column_name 'fax_organisme') NULL,
    email_organisme varchar(100) OPTIONS(column_name 'email_organisme') NULL,
    url_organisme varchar(255) OPTIONS(column_name 'url_organisme') NULL,
    url_logo varchar(255) OPTIONS(column_name 'url_logo') NULL,
    id_parent int4 OPTIONS(column_name 'id_parent') NULL
)
SERVER geonaturedbserver
OPTIONS (schema_name 'utilisateurs', table_name 'bib_organismes');

-- TABLE cor_data_actor
CREATE FOREIGN TABLE utilisateurs.cor_dataset_actor (
    id_cda int4 OPTIONS(column_name 'id_cda') NOT NULL,
    id_dataset int4 OPTIONS(column_name 'id_dataset') NULL,
    id_role int4 OPTIONS(column_name 'id_role') NULL,
    id_organism int4 OPTIONS(column_name 'id_organism') NULL,
    id_nomenclature_actor_role int4 OPTIONS(column_name 'id_nomenclature_actor_role') NULL
)
SERVER geonaturedbserver
OPTIONS (schema_name 'gn_meta', table_name 'cor_dataset_actor');

--CRÉATION VUE MATÉRIALISÉE
create MATERIALIZED VIEW atlas.vm_organismes
AS SELECT cd_ref, count(*) as nb_observations, id_organisme , nom_organisme , adresse_organisme , cp_organisme , ville_organisme , tel_organisme , email_organisme , url_organisme ,url_logo
   FROM utilisateurs.bib_organismes bo
     JOIN utilisateurs.cor_dataset_actor cda ON bo.id_organisme =cda.id_organism 
     JOIN synthese.synthese s ON s.id_dataset =cda.id_dataset 
     JOIN taxonomie.taxref t on s.cd_nom=t.cd_nom
  group by t.cd_ref, bo.id_organisme, bo.nom_organisme, bo.adresse_organisme, bo.cp_organisme, bo.ville_organisme, bo.tel_organisme, bo.email_organisme, bo.url_organisme, bo.url_logo
  with data;

--Fonction pour rafraichir toutes les vues matérialisées d'un schéma

--USAGE : SELECT RefreshAllMaterializedViews('atlas');
CREATE OR REPLACE FUNCTION RefreshAllMaterializedViews(schema_arg TEXT DEFAULT 'public')
RETURNS INT AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;
    FOR r IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
    LOOP
        RAISE NOTICE 'Refreshing %.%', schema_arg, r.matviewname;
        --EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || r.matviewname; --Si vous utilisez une version inférieure à PostgreSQL 9.4
        EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || schema_arg || '.' || r.matviewname;
    END LOOP;

    RETURN 1;
END
$$ LANGUAGE plpgsql;

-- Rafraichissement des vues contenant les données de l'atlas
CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data()
RETURNS VOID AS $$
BEGIN

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_observations_mailles;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_mois;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_altitudes;

  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_cor_taxon_attribut;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_search_taxon;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_medias;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_taxons_plus_observes;
  REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.vm_organismes;

END
$$ LANGUAGE plpgsql;
