-- +-----------------------------------------------------------------------------------------------+
-- Classic stats
CREATE  MATERIALIZED VIEW atlas.vm_area_stats AS
    SELECT
        vla.id_area,
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.observateurs) AS nb_observers,
        count(DISTINCT tax.cd_ref) FILTER (WHERE tax.patrimonial = 'oui') AS nb_taxon_patrimonial,
        min(extract(YEAR FROM obs.dateobs)) AS yearmin,
        max(extract(YEAR FROM obs.dateobs)) AS yearmax,
        count(DISTINCT u.id_organisme) AS nb_organism,
        count(distinct cor_statut.cd_ref) FILTER (WHERE cor_statut.statut_menace is not null) as nb_taxon_menace,
        count(distinct cor_statut.cd_ref) FILTER (WHERE cor_statut.protege is true) as nb_taxon_protege
    FROM atlas.vm_observations AS obs
        JOIN atlas.vm_cor_area_synthese AS vcas
            ON obs.id_observation = vcas.id_synthese
        JOIN atlas.vm_l_areas AS vla
            ON vla.id_area = vcas.id_area
        JOIN atlas.vm_bib_areas_types AS bat
            ON bat.id_type = vla.id_type
        JOIN atlas.vm_taxons AS tax
            ON tax.cd_ref = obs.cd_ref
        LEFT JOIN gn_meta.cor_dataset_actor AS rcda
            ON obs.id_dataset = rcda.id_dataset
        LEFT JOIN utilisateurs.bib_organismes AS u
            ON rcda.id_organism = u.id_organisme
        left JOIN atlas.vm_cor_areas AS cor_areas ON cor_areas.id_area = vcas.id_area
        left JOIN atlas.vm_cor_taxon_statut_area AS cor_statut on cor_statut.id_area = cor_areas.id_area_parent AND cor_statut.cd_ref = tax.cd_ref
    WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    GROUP BY vla.id_area
WITH DATA ;

CREATE UNIQUE INDEX ON atlas.vm_area_stats
    USING btree (id_area);


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by organism
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_taxonomy_group as
    SELECT
        vla.id_area,
        tax.group2_inpn,
        count(DISTINCT obs.id_observation) AS nb_obs,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.observateurs) AS nb_observers,
        count(DISTINCT tax.cd_ref) FILTER (WHERE tax.patrimonial = 'oui') AS nb_taxon_patrimonial,
        min(extract(YEAR FROM obs.dateobs)) AS yearmin,
        max(extract(YEAR FROM obs.dateobs)) AS yearmax,
        count(DISTINCT u.id_organisme) AS nb_organism,
        count(distinct cor_statut.cd_ref) FILTER (WHERE cor_statut.statut_menace IS NOT NULL) AS nb_taxon_menace,
        count(distinct cor_statut.cd_ref) FILTER (WHERE cor_statut.protege IS true) AS nb_taxon_protege,
        (
            SELECT count(*)
            FROM atlas.vm_taxons AS taxon
            WHERE taxon.group2_inpn = tax.group2_inpn
        ) AS nb_species_in_teritory
    FROM atlas.vm_observations AS obs
        JOIN atlas.vm_cor_area_synthese AS vcas
            ON obs.id_observation = vcas.id_synthese
        JOIN atlas.vm_l_areas AS vla
            ON vla.id_area = vcas.id_area
        JOIN atlas.vm_bib_areas_types AS bat
            ON bat.id_type = vla.id_type
        JOIN atlas.vm_taxons AS tax
            ON tax.cd_ref = obs.cd_ref
        LEFT JOIN gn_meta.cor_dataset_actor AS rcda
            ON obs.id_dataset = rcda.id_dataset
        LEFT JOIN utilisateurs.bib_organismes AS u
            ON rcda.id_organism = u.id_organisme
        left JOIN atlas.vm_cor_areas AS cor_areas ON cor_areas.id_area = vcas.id_area
        left JOIN atlas.vm_cor_taxon_statut_area AS cor_statut on cor_statut.id_area = cor_areas.id_area_parent AND cor_statut.cd_ref = tax.cd_ref
    WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    GROUP BY vla.id_area, tax.group2_inpn
WITH DATA ;

CREATE UNIQUE INDEX ON atlas.vm_area_stats_by_taxonomy_group
    USING btree (id_area, group2_inpn);


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by organism
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_organism AS
    SELECT
        cas.id_area,
        u.nom_organisme AS nom_organism,
        count(DISTINCT obs.cd_ref) AS nb_species,
        count(DISTINCT obs.id_observation) AS nb_obs
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

CREATE UNIQUE INDEX ON atlas.vm_area_stats_by_organism
    USING btree (id_area, nom_organism);

