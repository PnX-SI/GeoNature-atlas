
CREATE SCHEMA synthese AUTHORIZATION geonatatlas;
CREATE SCHEMA taxonomie AUTHORIZATION geonatatlas;
CREATE SCHEMA utilisateurs AUTHORIZATION geonatatlas;
CREATE SCHEMA meta AUTHORIZATION geonatatlas;
CREATE SCHEMA layers AUTHORIZATION geonatatlas;
CREATE SCHEMA atlas AUTHORIZATION geonatatlas;

--PUBLIC

CREATE FOREIGN TABLE public.cor_boolean
(
  expression character varying(25) NOT NULL,
  bool boolean NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'public', table_name 'cor_boolean');
ALTER TABLE public.cor_boolean OWNER TO geonatatlas;
GRANT ALL ON TABLE public.cor_boolean TO geonatatlas;

INSERT INTO public.cor_boolean VALUES('oui',true);
INSERT INTO public.cor_boolean VALUES('non',false);

--UTILISATEURS
CREATE FOREIGN TABLE utilisateurs.bib_organismes
(
  nom_organisme character varying(100) NOT NULL,
  adresse_organisme character varying(128),
  cp_organisme character varying(5),
  ville_organisme character varying(100),
  tel_organisme character varying(14),
  fax_organisme character varying(14),
  email_organisme character varying(100),
  id_organisme integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'bib_organismes');
ALTER TABLE utilisateurs.bib_organismes OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.bib_organismes TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.bib_droits
(
  id_droit integer NOT NULL,
  nom_droit character varying(50),
  desc_droit text
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'bib_droits');
ALTER TABLE utilisateurs.bib_droits OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.bib_droits TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.bib_unites
(
  nom_unite character varying(50) NOT NULL,
  adresse_unite character varying(128),
  cp_unite character varying(5),
  ville_unite character varying(100),
  tel_unite character varying(14),
  fax_unite character varying(14),
  email_unite character varying(100),
  id_unite integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'bib_unites');
ALTER TABLE utilisateurs.bib_unites OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.bib_unites TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.t_roles
(
  groupe boolean NOT NULL DEFAULT false,
  id_role integer NOT NULL,
  identifiant character varying(100),
  nom_role character varying(50),
  prenom_role character varying(50),
  desc_role text,
  pass character varying(100),
  email character varying(250),
  id_organisme integer,
  organisme character(32),
  id_unite integer,
  remarques text,
  pn boolean,
  session_appli character varying(50),
  date_insert timestamp without time zone,
  date_update timestamp without time zone
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 't_roles');
ALTER TABLE utilisateurs.t_roles OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.t_roles TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.t_menus
(
  id_menu serial NOT NULL,
  nom_menu character varying(50) NOT NULL,
  desc_menu text,
  id_application integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 't_menus');
ALTER TABLE utilisateurs.t_menus OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.t_menus TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.t_applications
(
  id_application serial NOT NULL,
  nom_application character varying(50) NOT NULL,
  desc_application text
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 't_applications');
ALTER TABLE utilisateurs.t_applications OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.t_applications TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.cor_role_droit_application
(
  id_role integer NOT NULL,
  id_droit integer NOT NULL,
  id_application integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'cor_role_droit_application');
ALTER TABLE utilisateurs.cor_role_droit_application OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.cor_role_droit_application TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.cor_role_menu
(
  id_role integer NOT NULL,
  id_menu integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'cor_role_menu');
ALTER TABLE utilisateurs.cor_role_menu OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.cor_role_menu TO geonatatlas;

CREATE FOREIGN TABLE utilisateurs.cor_roles
(
  id_role_groupe integer NOT NULL,
  id_role_utilisateur integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'utilisateurs', table_name 'cor_roles');
ALTER TABLE utilisateurs.cor_roles OWNER TO geonatatlas;
GRANT ALL ON TABLE utilisateurs.cor_roles TO geonatatlas;

--SYNTHESE
CREATE FOREIGN TABLE synthese.bib_criteres_synthese
(
  id_critere_synthese integer NOT NULL,
  code_critere_synthese character varying(3),
  nom_critere_synthese character varying(90),
  tri integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'bib_criteres_synthese');
ALTER TABLE synthese.bib_criteres_synthese OWNER TO geonatatlas;
GRANT ALL ON TABLE synthese.bib_criteres_synthese TO geonatatlas;

CREATE FOREIGN TABLE synthese.bib_sources
(
  id_source integer NOT NULL,
  nom_source character varying(255),
  desc_source text,
  host character varying(100),
  port integer,
  username character varying(50),
  pass character varying(50),
  db_name character varying(50),
  db_schema character varying(50),
  db_table character varying(50),
  db_field character varying(50),
  url character varying(255),
  target character varying(10),
  picto character varying(255),
  groupe character varying(50) NOT NULL,
  actif boolean NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'bib_sources');
ALTER TABLE synthese.bib_sources OWNER TO geonatatlas;
GRANT ALL ON TABLE synthese.bib_sources TO geonatatlas;

CREATE FOREIGN TABLE synthese.cor_unite_synthese
(
  id_unite_geo integer NOT NULL,
  id_synthese integer NOT NULL,
  dateobs date,
  cd_nom integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'cor_unite_synthese');
ALTER TABLE synthese.cor_unite_synthese OWNER TO geonatatlas;
GRANT ALL ON TABLE synthese.cor_unite_synthese TO geonatatlas;

CREATE FOREIGN TABLE synthese.cor_zonesstatut_synthese
(
  id_zone integer NOT NULL,
  id_synthese integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'cor_zonesstatut_synthese');
ALTER TABLE synthese.cor_zonesstatut_synthese OWNER TO geonatatlas;
GRANT ALL ON TABLE synthese.cor_zonesstatut_synthese TO geonatatlas;

CREATE FOREIGN TABLE synthese.syntheseff
(
  id_synthese serial NOT NULL,
  id_source integer,
  id_fiche_source character varying(50),
  code_fiche_source character varying(50),
  id_organisme integer,
  id_protocole integer,
  id_precision integer,
  cd_nom integer,
  insee character(5),
  dateobs date NOT NULL,
  observateurs character varying(255),
  determinateur character varying(255),
  altitude_retenue integer,
  remarques text,
  date_insert timestamp without time zone,
  date_update timestamp without time zone,
  derniere_action character(1),
  supprime boolean,
  the_geom_point geometry('POINT',3857),
  id_lot integer,
  id_critere_synthese integer,
  the_geom_3857 geometry,
  effectif_total integer,
  the_geom_2154 geometry
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'synthese', table_name 'syntheseff');
ALTER TABLE synthese.syntheseff OWNER TO geonatatlas;
GRANT ALL ON TABLE synthese.syntheseff TO geonatatlas;

--TAXONOMIE
CREATE FOREIGN TABLE taxonomie.bib_attributs
(
  id_attribut integer NOT NULL,
  nom_attribut character varying(255) NOT NULL,
  label_attribut character varying(50) NOT NULL,
  liste_valeur_attribut text NOT NULL,
  obligatoire boolean NOT NULL,
  desc_attribut text,
  type_attribut character varying(50),
  type_widget character varying(50),
  regne character varying(20),
  group2_inpn character varying(255),
  id_theme integer,
  ordre integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_attributs');
ALTER TABLE taxonomie.bib_attributs OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_attributs TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_listes
(
  id_liste integer NOT NULL,
  nom_liste character varying(255) NOT NULL,
  desc_liste text,
  picto character varying(50),
  regne character varying(20),
  group2_inpn character varying(255)
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_listes');
ALTER TABLE taxonomie.bib_listes OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_listes TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_noms
(
  id_nom serial NOT NULL,
  cd_nom integer,
  cd_ref integer,
  nom_francais character varying(255)
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_noms');
ALTER TABLE taxonomie.bib_noms OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_noms TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_taxref_categories_lr
(
  id_categorie_france character(2) NOT NULL,
  categorie_lr character varying(50) NOT NULL,
  nom_categorie_lr character varying(255) NOT NULL,
  desc_categorie_lr character varying(255)
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_taxref_categories_lr');
ALTER TABLE taxonomie.bib_taxref_categories_lr OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_taxref_categories_lr TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_taxref_habitats
(
  id_habitat integer NOT NULL,
  nom_habitat character varying(50) NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_taxref_habitats');
ALTER TABLE taxonomie.bib_taxref_habitats OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_taxref_habitats TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_taxref_rangs
(
  id_rang character(4) NOT NULL,
  nom_rang character varying(20) NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_taxref_rangs');
ALTER TABLE taxonomie.bib_taxref_rangs OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_taxref_rangs TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_taxref_statuts
(
  id_statut character(1) NOT NULL,
  nom_statut character varying(50) NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_taxref_statuts');
ALTER TABLE taxonomie.bib_taxref_statuts OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_taxref_statuts TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.bib_themes
(
  id_theme integer NOT NULL,
  nom_theme character varying(20),
  desc_theme character varying(255),
  ordre integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'bib_themes');
ALTER TABLE taxonomie.bib_themes OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.bib_themes TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.taxref_liste_rouge_fr
(
  id_lr serial NOT NULL,
  ordre_statut integer,
  vide character varying(255),
  cd_nom integer,
  cd_ref integer,
  nomcite character varying(255),
  nom_scientifique character varying(255),
  auteur character varying(255),
  nom_vernaculaire character varying(255),
  nom_commun character varying(255),
  rang character(4),
  famille character varying(50),
  endemisme character varying(255),
  population character varying(255),
  commentaire text,
  id_categorie_france character(2) NOT NULL,
  criteres_france character varying(255),
  liste_rouge character varying(255),
  fiche_espece character varying(255),
  tendance character varying(255),
  liste_rouge_source character varying(255),
  annee_publication integer,
  categorie_lr_europe character varying(2),
  categorie_lr_mondiale character varying(5)
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'taxref_liste_rouge_fr');
ALTER TABLE taxonomie.taxref_liste_rouge_fr OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.taxref_liste_rouge_fr TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.taxref
(
  cd_nom integer NOT NULL,
  id_statut character(1),
  id_habitat integer,
  id_rang character(4),
  regne character varying(20),
  phylum character varying(50),
  classe character varying(50),
  ordre character varying(50),
  famille character varying(50),
  cd_taxsup integer,
  cd_ref integer,
  lb_nom character varying(100),
  lb_auteur character varying(250),
  nom_complet character varying(255),
  nom_valide character varying(255),
  nom_vern character varying(1000),
  nom_vern_eng character varying(500),
  group1_inpn character varying(50),
  group2_inpn character varying(50),
  nom_complet_html character varying(500),
  cd_sup integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'taxref');
ALTER TABLE taxonomie.taxref OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.taxref TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.taxref_protection_articles
(
  cd_protection character varying(20) NOT NULL,
  article character varying(100),
  intitule text,
  arrete text,
  url character varying(250),
  date_arrete integer,
  rang_niveau integer,
  lb_article text,
  type_protection character varying(250),
  concerne_mon_territoire boolean,
  url_inpn character varying(250),
  cd_doc integer
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'taxref_protection_articles');
ALTER TABLE taxonomie.taxref_protection_articles OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.taxref_protection_articles TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.taxref_protection_especes
(
  cd_nom integer NOT NULL,
  cd_protection character varying(20) NOT NULL,
  nom_cite character varying(200),
  syn_cite character varying(200),
  nom_francais_cite character varying(100),
  precisions text,
  cd_nom_cite character varying(255) NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'taxref_protection_especes');
ALTER TABLE taxonomie.taxref_protection_especes OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.taxref_protection_especes TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.cor_taxon_attribut
(
  id_attribut integer NOT NULL,
  valeur_attribut character varying(50) NOT NULL,
  cd_ref integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'cor_taxon_attribut');
ALTER TABLE taxonomie.cor_taxon_attribut OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.cor_taxon_attribut TO geonatatlas;

CREATE FOREIGN TABLE taxonomie.cor_nom_liste
(
  id_liste integer NOT NULL,
  id_nom integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'taxonomie', table_name 'cor_nom_liste');
ALTER TABLE taxonomie.cor_nom_liste OWNER TO geonatatlas;
GRANT ALL ON TABLE taxonomie.cor_nom_liste TO geonatatlas;

--LAYERS
CREATE FOREIGN TABLE layers.l_zonesstatut
(
  id_zone integer NOT NULL,
  id_type integer NOT NULL,
  id_mnhn character varying(20),
  nomzone character varying(250),
  the_geom geometry('MULTIPOLYGON', 2154 )
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'layers', table_name 'l_zonesstatut');
ALTER TABLE layers.l_zonesstatut OWNER TO geonatatlas;
GRANT ALL ON TABLE layers.l_zonesstatut TO geonatatlas;

CREATE FOREIGN TABLE layers.l_secteurs
(
  nom_secteur character varying(50),
  id_secteur integer NOT NULL,
  the_geom geometry('MULTIPOLYGON', 2154 )
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'layers', table_name 'l_secteurs');
ALTER TABLE layers.l_secteurs OWNER TO geonatatlas;
GRANT ALL ON TABLE layers.l_secteurs TO geonatatlas;

CREATE FOREIGN TABLE layers.bib_typeszones
(
  id_type integer NOT NULL,
  typezone character varying(200)
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'layers', table_name 'bib_typeszones');
ALTER TABLE layers.bib_typeszones OWNER TO geonatatlas;
GRANT ALL ON TABLE layers.bib_typeszones TO geonatatlas;

CREATE FOREIGN TABLE layers.l_communes
(
  insee character(5) NOT NULL,
  idbdcarto bigint,
  commune_maj character varying(50),
  commune_min character varying(50),
  inseedep character varying(3),
  nomdep character varying(30),
  inseereg character varying(2),
  nomreg character varying(30),
  inseearr character varying(1),
  inseecan character varying(2),
  statut character varying(20),
  xcom bigint,
  ycom bigint,
  surface bigint,
  epci character varying(40),
  coeur_aoa character varying(5),
  codenum integer,
  pays character varying(50),
  id_secteur integer,
  saisie boolean,
  organisme boolean,
  id_secteur_fp integer,
  the_geom geometry('MULTIPOLYGON', 2154 )
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'layers', table_name 'l_communes');
ALTER TABLE layers.l_communes OWNER TO geonatatlas;
GRANT ALL ON TABLE layers.l_communes TO geonatatlas;

--META
CREATE FOREIGN TABLE meta.t_protocoles
(
  id_protocole integer NOT NULL,
  nom_protocole character varying(250),
  question text,
  objectifs text,
  methode text,
  avancement character varying(50),
  date_debut date,
  date_fin date
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'meta', table_name 't_protocoles');
ALTER TABLE meta.t_protocoles OWNER TO geonatatlas;
GRANT ALL ON TABLE meta.t_protocoles TO geonatatlas;

CREATE FOREIGN TABLE meta.t_precisions
(
  id_precision integer NOT NULL,
  nom_precision character varying(50),
  desc_precision text
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'meta', table_name 't_precisions');
ALTER TABLE meta.t_precisions OWNER TO geonatatlas;
GRANT ALL ON TABLE meta.t_precisions TO geonatatlas;

CREATE FOREIGN TABLE meta.bib_programmes
(
  id_programme integer NOT NULL,
  nom_programme character varying(255),
  desc_programme text,
  programme_public boolean,
  desc_programme_public text,
  actif boolean
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'meta', table_name 'bib_programmes');
ALTER TABLE meta.bib_programmes OWNER TO geonatatlas;
GRANT ALL ON TABLE meta.bib_programmes TO geonatatlas;

CREATE FOREIGN TABLE meta.bib_lots
(
  id_lot integer NOT NULL,
  nom_lot character varying(255),
  desc_lot text,
  menu_cf boolean DEFAULT false,
  pn boolean DEFAULT true,
  menu_inv boolean DEFAULT false,
  id_programme integer NOT NULL
)
  SERVER geonaturedbserver
  OPTIONS (schema_name 'meta', table_name 'bib_lots');
ALTER TABLE meta.bib_lots OWNER TO geonatatlas;
GRANT ALL ON TABLE meta.bib_lots TO geonatatlas;

--DROP TABLE atlas.bib_altitudes;
CREATE TABLE atlas.bib_altitudes
(
  id_altitude integer NOT NULL,
  altitude_min integer NOT NULL,
  altitude_max integer NOT NULL,
  label_altitude character varying(255),
  CONSTRAINT bib_altitudes_pk PRIMARY KEY (id_altitude)
);
ALTER TABLE atlas.bib_altitudes OWNER TO geonatatlas;
GRANT ALL ON TABLE atlas.bib_altitudes TO geonatatlas;

INSERT INTO atlas.bib_altitudes VALUES(1,0,499);
INSERT INTO atlas.bib_altitudes VALUES(2,500,999);
INSERT INTO atlas.bib_altitudes VALUES(3,1000,1499);
INSERT INTO atlas.bib_altitudes VALUES(4,1500,1999);
INSERT INTO atlas.bib_altitudes VALUES(5,2000,2499);
INSERT INTO atlas.bib_altitudes VALUES(6,2500,2999);
INSERT INTO atlas.bib_altitudes VALUES(7,3000,3499);
INSERT INTO atlas.bib_altitudes VALUES(8,3500,3999);
INSERT INTO atlas.bib_altitudes VALUES(9,4000,4102);
UPDATE atlas.bib_altitudes set label_altitude = '_' || altitude_min || '_' || altitude_max+1;

CREATE OR REPLACE FUNCTION taxonomie.find_cdref(id integer)
  RETURNS integer AS
$BODY$
  DECLARE ref integer;
  BEGIN
  SELECT INTO ref cd_ref FROM taxonomie.taxref WHERE cd_nom = id;
  return ref;
  END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;

--VUES MATERIALISEES

--DROP materialized view taxonomie.vm_taxref;
CREATE materialized view atlas.vm_taxref AS
SELECT * FROM taxonomie.taxref;
create unique index on atlas.vm_taxref (cd_nom);
create index on atlas.vm_taxref (cd_ref);
create index on atlas.vm_taxref (cd_taxsup);
create index on atlas.vm_taxref (lb_nom);
create index on atlas.vm_taxref (nom_complet);
create index on atlas.vm_taxref (nom_valide);

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
ALTER FUNCTION atlas.find_all_taxons_childs(integer)
  OWNER TO geonatatlas;
  
--DROP materialized view atlas.vm_observations; 
CREATE MATERIALIZED VIEW atlas.vm_observations AS 
    SELECT s.id_synthese,
        s.id_source,
        s.id_fiche_source,
        s.code_fiche_source,
        s.id_protocole,
        s.id_precision,
        s.insee,
        s.dateobs,
        s.observateurs,
        s.determinateur,
        s.altitude_retenue,
        s.remarques,
        s.date_insert,
        s.date_update,
        s.derniere_action,
        s.the_geom_point::geometry('POINT',3857),
        s.id_lot,
        s.id_critere_synthese,
        s.effectif_total,
        tx.cd_ref,
        st_asgeojson(ST_Transform(ST_SetSrid(s.the_geom_point, 3857), 4326)) as geojson_point
    FROM synthese.syntheseff s
    LEFT JOIN taxonomie.taxref tx ON tx.cd_nom = s.cd_nom
    WHERE s.supprime = FALSE
    AND s.id_organisme = 2;

ALTER TABLE atlas.vm_observations
  OWNER TO geonatatlas;
create unique index on atlas.vm_observations (id_synthese);
create index on atlas.vm_observations (cd_ref);
create index on atlas.vm_observations (insee);
create index on atlas.vm_observations (altitude_retenue);
create index on atlas.vm_observations (dateobs);
CREATE INDEX index_gist_synthese_the_geom_point ON atlas.vm_observations USING gist (the_geom_point);

--DROP MATERIALIZED VIEW atlas.vm_taxons;
CREATE materialized view atlas.vm_taxons AS
WITH obs_min_taxons AS (SELECT cd_ref, min(date_part('year'::text, dateobs)) AS yearmin FROM atlas.vm_observations GROUP BY cd_ref),
tx_ref AS (
  SELECT
    tx.cd_ref,
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
    h.nom_habitat,
    r.nom_rang,
    st.nom_statut
  FROM atlas.vm_taxref tx
     LEFT JOIN taxonomie.bib_taxref_habitats h ON h.id_habitat = tx.id_habitat
     LEFT JOIN taxonomie.bib_taxref_rangs r ON r.id_rang = tx.id_rang
     LEFT JOIN taxonomie.bib_taxref_statuts st ON st.id_statut = tx.id_statut
  WHERE tx.cd_ref IN (SELECT cd_ref FROM obs_min_taxons)
  AND tx.cd_nom = tx.cd_ref
),
my_taxons AS (
SELECT DISTINCT taxonomie.find_cdref(cd_nom) AS cd_ref, f2.bool AS patrimonial, f3.bool AS protection_stricte 
FROM taxonomie.bib_noms n
LEFT JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = n.cd_ref
JOIN cor_boolean f2 ON f2.expression::text = cta.valeur_attribut::text AND cta.id_attribut = 1
JOIN cor_boolean f3 ON f2.expression::text = cta.valeur_attribut::text AND cta.id_attribut = 2
WHERE taxonomie.find_cdref(cd_nom) IN(SELECT cd_ref FROM obs_min_taxons)
)
SELECT tx.*, t.patrimonial, t.protection_stricte, omt.yearmin
FROM tx_ref tx
LEFT JOIN obs_min_taxons omt ON omt.cd_ref = tx.cd_ref
LEFT JOIN my_taxons t ON t.cd_ref = tx.cd_ref;
create unique index on atlas.vm_taxons (cd_ref);

-- Function: atlas.create_vm_altitudes()

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
    
    FOR mesaltitudes IN SELECT * FROM atlas.bib_altitudes LOOP
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
    create unique index on atlas.vm_altitudes (cd_ref);

    RETURN monsql;
    
  END;
  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION atlas.create_vm_altitudes()
  OWNER TO geonatatlas;

select atlas.create_vm_altitudes();

CREATE MATERIALIZED VIEW atlas.vm_search_taxon AS 
SELECT tx.cd_nom, tx.cd_ref, COALESCE(tx.lb_nom || ' | ' || tx.nom_vern, tx.lb_nom) AS nom_search FROM atlas.vm_taxref tx JOIN atlas.vm_taxons t ON t.cd_ref = tx.cd_ref;
create UNIQUE index on atlas.vm_search_taxon(cd_nom);
create index on atlas.vm_search_taxon(cd_ref);
create index on atlas.vm_search_taxon(nom_search); 


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
create unique index on atlas.vm_mois (cd_ref);


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

ALTER TABLE atlas.bib_taxref_rangs
    OWNER TO geonatatlas;



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
        EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || r.matviewname; 
        --EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || schema_arg || '.' || r.matviewname; 
    END LOOP;

    RETURN 1;
END 
$$ LANGUAGE plpgsql;




