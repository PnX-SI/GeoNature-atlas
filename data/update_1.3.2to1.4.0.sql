DROP MATERIALIZED VIEW atlas.vm_search_taxon;

CREATE MATERIALIZED VIEW atlas.vm_search_taxon AS
SELECT t.cd_nom,
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
        concat(t_1.nom_vern, ' =  <i> ', t_1.nom_valide, '</i>') AS search_name,
        t_1.nom_valide,
        t_1.lb_nom
  FROM atlas.vm_taxref t_1
  WHERE t_1.nom_vern IS NOT NULL AND t_1.cd_nom = t_1.cd_ref
) t
JOIN atlas.vm_taxons taxons ON taxons.cd_ref = t.cd_ref;



CREATE UNIQUE INDEX ON atlas.vm_search_taxon (cd_nom, search_name);
CREATE INDEX ON atlas.vm_search_taxon(cd_ref);
CREATE INDEX trgm_idx ON atlas.vm_search_taxon USING GIST (search_name gist_trgm_ops);

-- index unique vm_taxons
CREATE UNIQUE INDEX ON atlas.vm_taxons (cd_ref);


-- update vm_medias

ALTER FOREIGN TABLE taxonomie.t_medias ADD COLUMN licence character varying(100);
ALTER FOREIGN TABLE taxonomie.t_medias ADD COLUMN source character varying(25);

DROP MATERIALIZED VIEW atlas.vm_taxons_plus_observes;
DROP MATERIALIZED VIEW atlas.vm_medias;

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

 CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx
  ON atlas.vm_taxons_plus_observes
  USING btree
  (cd_ref);



DROP MATERIALIZED VIEW atlas.vm_observations_mailles;

CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS 
 SELECT obs.cd_ref,
    obs.id_observation,
    m.id_maille,
    m.geojson_maille,
    date_part('year', dateobs) as annee
   FROM atlas.vm_observations obs
     JOIN atlas.t_mailles_territoire m ON st_intersects(obs.the_geom_point, m.the_geom)
WITH DATA;


create unique index on atlas.vm_observations_mailles (id_observation);
create index on atlas.vm_observations_mailles (id_maille);
create index on atlas.vm_observations_mailles (cd_ref);
create index on atlas.vm_observations_mailles (geojson_maille);

