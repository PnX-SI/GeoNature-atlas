
DROP MATERIALIZED VIEW IF EXISTS atlas.vm_taxons_plus_observes;

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

-- Index: atlas.vm_taxons_plus_observes_cd_ref_idx

-- DROP INDEX atlas.vm_taxons_plus_observes_cd_ref_idx;

CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx
  ON atlas.vm_taxons_plus_observes
  USING btree
  (cd_ref);
  
-- Add GRAND SELECT to 
-- Si votre utilisateur PostgreSQL en lecture seule sur ces vues n'est pas "geonatatlas" 
-- (celui utilisé par l'application web de l'atlas, user_pg dans main/configuration/settings.ini),
-- vous devez modifier l'utilisateur avant d'exécuter ce script.

GRANT SELECT ON TABLE atlas.bib_altitudes TO geonatatlas;
