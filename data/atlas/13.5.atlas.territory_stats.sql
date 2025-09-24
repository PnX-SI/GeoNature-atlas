-- +-----------------------------------------------------------------------------------------------+
-- Classic stats
DROP materialized view IF EXISTS atlas.vm_area_stats ;
CREATE MATERIALIZED VIEW atlas.vm_area_stats AS
    SELECT                                                                                     
        ta.id_area,
        COUNT(DISTINCT ta.id_observation) AS nb_obs,
        COUNT(DISTINCT ta.cd_ref) AS nb_species,
        COUNT(DISTINCT ta.observateurs) AS nb_observers,
        COUNT(DISTINCT u.id_organisme) AS nb_organism,
        MIN(extract(YEAR FROM ta.dateobs)) AS yearmin,
        MAX(extract(YEAR FROM ta.dateobs)) AS yearmax,
        COUNT(DISTINCT t.cd_ref) FILTER (WHERE t.patrimonial = 'oui') AS nb_taxon_patrimonial,
        COUNT(DISTINCT t.cd_ref) FILTER (WHERE t.protection_stricte = 'oui') AS nb_taxon_protege,
        COUNT(DISTINCT ta.cd_ref) FILTER (WHERE ta.threatened = true and ta.cd_sig = :'perimetre_liste_rouge') AS nb_taxon_threatened,
        area.description
    FROM atlas.vm_taxons_areas AS ta
        LEFT JOIN atlas.vm_taxons AS t
            ON t.cd_ref=ta.cd_ref
        LEFT JOIN gn_meta.cor_dataset_actor AS rcda
            ON ta.id_dataset = rcda.id_dataset
        LEFT JOIN utilisateurs.bib_organismes AS u
            ON rcda.id_organism = u.id_organisme
        LEFT JOIN atlas.vm_l_areas AS area
                ON area.id_area = ta.id_area
    WHERE ta.type_code = ANY(SELECT * from string_to_table(:'type_code', ','))
    GROUP BY ta.id_area, area.description
WITH DATA;


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by taxonomy_group
DROP materialized view IF EXISTS atlas.vm_area_stats_by_taxonomy_group;
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_taxonomy_group AS
    SELECT
        ta.id_area,
        COUNT(DISTINCT ta.id_observation) AS nb_obs,
        COUNT(DISTINCT ta.cd_ref) AS nb_species,
        t.group2_inpn,
        COUNT(DISTINCT t.cd_ref) FILTER (WHERE t.patrimonial = 'oui') AS nb_patrominal,
        COUNT(DISTINCT t.cd_ref) FILTER (WHERE t.protection_stricte = 'oui') AS nb_taxon_protege,
        COUNT(DISTINCT ta.cd_ref) FILTER (WHERE ta.threatened = true and ta.cd_sig = :'perimetre_liste_rouge') AS nb_taxon_threatened,
        (
            SELECT COUNT(*)
            FROM atlas.vm_taxons AS taxon
            WHERE taxon.group2_inpn = t.group2_inpn
        ) AS nb_species_in_teritory
    FROM atlas.vm_taxons_areas ta
        JOIN atlas.vm_taxons AS t
            ON t.cd_ref = ta.cd_ref
    WHERE ta.type_code = ANY(SELECT * from string_to_table(:'type_code', ','))
        AND t.group2_inpn IS NOT NULL
    GROUP BY ta.id_area, t.group2_inpn
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
