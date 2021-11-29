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