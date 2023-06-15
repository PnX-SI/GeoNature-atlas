-- Exclusion des médias supprimés
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
   FROM taxonomie.t_medias
WHERE NOT t_medias.supprime = true;

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
 LIMIT 12
WITH DATA;

-- View indexes:
CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx ON atlas.vm_taxons_plus_observes USING btree (cd_ref);
