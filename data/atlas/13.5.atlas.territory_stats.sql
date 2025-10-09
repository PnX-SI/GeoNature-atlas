-- +-----------------------------------------------------------------------------------------------+
-- Classic stats

CREATE MATERIALIZED VIEW atlas.vm_area_stats as
select 
		
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.observateurs) AS nb_observers,
        count(DISTINCT tax.cd_ref) FILTER (WHERE tax.patrimonial = 'oui') AS nb_taxon_patrimonial,
        min(extract(YEAR FROM obs.dateobs)) AS yearmin,
        max(extract(YEAR FROM obs.dateobs)) AS yearmax,
        count(DISTINCT u.id_organisme) AS nb_organism,
        count(distinct tam.cd_ref) FILTER (WHERE tam.statut_menace is not null) as nb_taxon_menace,
        count(distinct tam.cd_ref) FILTER (WHERE tam.protege is true) as nb_taxon_protege,
        vla.id_area 
 from atlas.vm_observations obs 
 join atlas.vm_cor_area_synthese vcas on obs.id_observation = vcas.id_synthese 
 join atlas.vm_l_areas vla on vla.id_area = vcas.id_area 
 JOIN atlas.vm_bib_areas_types AS bat ON  bat.id_type = vla.id_type
 join atlas.vm_taxons tax on tax.cd_ref = obs.cd_ref
 LEFT JOIN gn_meta.cor_dataset_actor AS rcda ON obs.id_dataset = rcda.id_dataset
 LEFT JOIN utilisateurs.bib_organismes AS u ON rcda.id_organism = u.id_organisme
 LEFT JOIN (
    SELECT cor.id_area_group, cor.id_area
    FROM atlas.vm_cor_areas cor 
    JOIN atlas.vm_l_areas ar ON cor.id_area = ar.id_area 
    JOIN atlas.vm_bib_areas_types bib ON bib.id_type = ar.id_type AND bib.type_code = 'DEP'
 ) as cor_dep ON vcas.id_area = cor_dep.id_area
 left JOIN atlas.vm_cor_taxon_statut_area AS tam ON tam.cd_ref = tax.cd_ref and tam.id_area = cor_dep.id_area_group
 WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
 GROUP BY vla.id_area;


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by organism
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_taxonomy_group as
select 
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.observateurs) AS nb_observers,
        count(DISTINCT tax.cd_ref) FILTER (WHERE tax.patrimonial = 'oui') AS nb_taxon_patrimonial,
        min(extract(YEAR FROM obs.dateobs)) AS yearmin,
        max(extract(YEAR FROM obs.dateobs)) AS yearmax,
        count(DISTINCT u.id_organisme) AS nb_organism,
        count(distinct tam.cd_ref) FILTER (WHERE tam.statut_menace is not null) as nb_taxon_menace,
        count(distinct tam.cd_ref) FILTER (WHERE tam.protege is true) as nb_taxon_protege,
        (
            SELECT count(*)
            FROM atlas.vm_taxons AS taxon
            WHERE taxon.group2_inpn = tax.group2_inpn
        ) AS nb_species_in_teritory,
        tax.group2_inpn,
        vla.id_area 
 from atlas.vm_observations obs 
 join atlas.vm_cor_area_synthese vcas on obs.id_observation = vcas.id_synthese 
 join atlas.vm_l_areas vla on vla.id_area = vcas.id_area 
 JOIN atlas.vm_bib_areas_types AS bat ON  bat.id_type = vla.id_type
 join atlas.vm_taxons tax on tax.cd_ref = obs.cd_ref
  LEFT JOIN (
    SELECT cor.id_area_group, cor.id_area
    FROM atlas.vm_cor_areas cor 
    JOIN atlas.vm_l_areas ar ON cor.id_area = ar.id_area 
    JOIN atlas.vm_bib_areas_types bib ON bib.id_type = ar.id_type AND bib.type_code = 'DEP'
 ) as cor_dep ON vcas.id_area = cor_dep.id_area
 LEFT JOIN gn_meta.cor_dataset_actor AS rcda ON obs.id_dataset = rcda.id_dataset
 LEFT JOIN utilisateurs.bib_organismes AS u ON rcda.id_organism = u.id_organisme
 left JOIN atlas.vm_cor_taxon_statut_area AS tam ON tam.cd_ref = tax.cd_ref and tam.id_area = cor_dep.id_area_group
 WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
 GROUP BY vla.id_area, tax.group2_inpn;



-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by organism
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_organism AS
    SELECT
        cas.id_area,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.id_observation) AS nb_obs,
        u.nom_organisme AS nom_organism
    FROM atlas.vm_cor_area_synthese AS cas
        JOIN atlas.vm_observations AS obs
            ON cas.id_synthese = obs.id_observation
        JOIN gn_meta.cor_dataset_actor AS rcda
            ON obs.id_dataset = rcda.id_dataset
        JOIN utilisateurs.bib_organismes AS u
            ON rcda.id_organism = u.id_organisme
    WHERE cas.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    GROUP BY cas.id_area, u.nom_organisme
WITH DATA;
