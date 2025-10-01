-- +-----------------------------------------------------------------------------------------------+
-- Classic stats
CREATE MATERIALIZED VIEW atlas.vm_area_stats AS
    SELECT
        cas.id_area,
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.observateurs) AS nb_observers,
        count(DISTINCT u.id_organisme) AS nb_organism,
        min(extract(YEAR FROM obs.dateobs)) AS yearmin,
        max(extract(YEAR FROM obs.dateobs)) AS yearmax,
        count(DISTINCT t.cd_ref) FILTER (WHERE t.patrimonial = 'oui') AS nb_taxon_patrimonial,
        count(DISTINCT t.cd_ref) FILTER (WHERE t.protection_stricte = 'oui') AS nb_taxon_protege,
        count(DISTINCT tam.cd_ref) as nb_taxon_threatened, 
        area.description
    FROM atlas.vm_cor_area_synthese AS cas
        JOIN atlas.vm_observations AS obs
            ON cas.id_synthese = obs.id_observation
        LEFT JOIN atlas.vm_taxons AS t
            ON t.cd_ref=obs.cd_ref
        LEFT JOIN gn_meta.cor_dataset_actor AS rcda
            ON obs.id_dataset = rcda.id_dataset
        LEFT JOIN utilisateurs.bib_organismes AS u
            ON rcda.id_organism = u.id_organisme
        LEFT JOIN atlas.vm_l_areas AS area
            ON area.id_area = cas.id_area
        LEFT JOIN atlas.cor_taxon_area_menace AS tam 
            ON tam.cd_ref = t.cd_ref
            AND cas.id_area = tam.id_area
        JOIN atlas.vm_bib_areas_types AS bat
            ON  bat.id_type = area.id_type
    WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    GROUP BY cas.id_area, area.description
WITH DATA;


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by taxonomy_group
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_taxonomy_group AS
    SELECT
        cas.id_area,
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        t.group2_inpn,
        count(DISTINCT t.cd_ref) FILTER (WHERE t.patrimonial = 'oui') AS nb_patrominal,
        count(DISTINCT t.cd_ref) FILTER (WHERE t.protection_stricte = 'oui') AS nb_taxon_protege,
        count(DISTINCT tam.cd_ref) as nb_taxon_threatened, 
        (
            SELECT count(*)
            FROM atlas.vm_taxons AS taxon
            WHERE taxon.group2_inpn = t.group2_inpn
        ) AS nb_species_in_teritory
    FROM atlas.vm_cor_area_synthese AS cas
        JOIN atlas.vm_observations AS obs
            ON cas.id_synthese = obs.id_observation
        JOIN atlas.vm_taxons AS t
            ON t.cd_ref = obs.cd_ref
        LEFT JOIN atlas.cor_taxon_area_menace AS tam 
            ON tam.cd_ref = t.cd_ref
            AND cas.id_area = tam.id_area
    WHERE cas.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
        AND t.group2_inpn IS NOT NULL
    GROUP BY cas.id_area, t.group2_inpn
WITH DATA;

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
