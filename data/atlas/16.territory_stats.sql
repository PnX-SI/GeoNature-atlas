-- +-----------------------------------------------------------------------------------------------+
-- Zonages ayant au moins une observation, filtrés par type_code
CREATE MATERIALIZED VIEW atlas.vm_areas_with_obs
AS SELECT DISTINCT vla.id_area,
    vla.area_name,
    vla.id_type,
    bat.type_name,
    bat.type_code
   FROM atlas.vm_l_areas vla
     JOIN atlas.vm_bib_areas_types bat ON bat.id_type = vla.id_type
     JOIN atlas.vm_cor_area_synthese vcas ON vla.id_area = vcas.id_area
     JOIN atlas.vm_observations obs ON obs.id_observation = vcas.id_synthese
  WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_areas_with_obs
    USING btree (id_area);

CREATE UNIQUE INDEX ON atlas.vm_areas_with_obs
    ON atlas.vm_areas_with_obs (type_code, area_name);
-- +-----------------------------------------------------------------------------------------------+
-- Classic stats
CREATE  MATERIALIZED VIEW atlas.vm_area_stats AS
    WITH base AS MATERIALIZED (
        SELECT
            vcas.id_area,
            obs.id_observation,
            obs.cd_ref,
            obs.observateurs,
            obs.dateobs,
            obs.id_dataset,
            tax.patrimonial
        FROM atlas.vm_bib_areas_types bat
        JOIN atlas.vm_l_areas vla
            ON vla.id_type = bat.id_type
        JOIN atlas.vm_cor_area_synthese vcas
            ON vcas.id_area = vla.id_area
        JOIN atlas.vm_observations obs
            ON obs.id_observation = vcas.id_synthese
        JOIN atlas.vm_taxons tax
            ON tax.cd_ref = obs.cd_ref
        WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    ),
    -- Stats des observations
    stats_obs AS (
        SELECT
            id_area,
            COUNT(DISTINCT id_observation) AS nb_obs,
            COUNT(DISTINCT cd_ref) AS nb_species,
            COUNT(DISTINCT observateurs) AS nb_observers,
            COUNT(DISTINCT cd_ref)
                FILTER (WHERE patrimonial = 'oui')
                AS nb_taxon_patrimonial,
            MIN(EXTRACT(YEAR FROM dateobs)) AS yearmin,
            MAX(EXTRACT(YEAR FROM dateobs)) AS yearmax
        FROM base
        GROUP BY id_area
    ),

    -- Stats des JDD
    area_datasets AS (
        SELECT DISTINCT id_area, id_dataset
        FROM base
    ),
    -- Stats des organismes
    stats_org AS (
        SELECT
            ad.id_area,
            COUNT(DISTINCT u.id_organisme) AS nb_organism
        FROM area_datasets ad
        JOIN gn_meta.cor_dataset_actor rcda
            ON rcda.id_dataset = ad.id_dataset
        JOIN utilisateurs.bib_organismes u
            ON u.id_organisme = rcda.id_organism
        GROUP BY ad.id_area
    ),
    -- Stats des taxons
    area_taxons AS (
        SELECT DISTINCT id_area, cd_ref
        FROM base
    ),

    -- Stats statuts protection / menace
    stats_statuts AS (
        SELECT
            at.id_area,
            COUNT(DISTINCT at.cd_ref)
                FILTER (WHERE cs.statut_menace IS NOT NULL)
                AS nb_taxon_menace,
            COUNT(DISTINCT at.cd_ref)
                FILTER (WHERE cs.protege IS TRUE)
                AS nb_taxon_protege
        FROM area_taxons at
        LEFT JOIN atlas.vm_cor_areas ca
            ON ca.id_area = at.id_area
        LEFT JOIN atlas.vm_cor_taxon_statut_area cs
            ON cs.id_area = ca.id_area_parent
        AND cs.cd_ref = at.cd_ref
        GROUP BY at.id_area
    )
    -- Final
    SELECT
        o.id_area,
        o.nb_obs,
        o.nb_species,
        o.nb_observers,
        o.nb_taxon_patrimonial,
        o.yearmin,
        o.yearmax,
        COALESCE(g.nb_organism, 0) AS nb_organism,
        COALESCE(s.nb_taxon_menace, 0) AS nb_taxon_menace,
        COALESCE(s.nb_taxon_protege, 0) AS nb_taxon_protege
    FROM stats_obs o
    LEFT JOIN stats_org g
        ON g.id_area = o.id_area
    LEFT JOIN stats_statuts s
        ON s.id_area = o.id_area;
WITH DATA ;

CREATE UNIQUE INDEX ON atlas.vm_area_stats
    USING btree (id_area);


-- +-----------------------------------------------------------------------------------------------+
-- Graph stats by organism
CREATE MATERIALIZED VIEW atlas.vm_area_stats_by_taxonomy_group as
    WITH base AS MATERIALIZED (
        SELECT
            vcas.id_area,
            tax.group2_inpn,
            obs.id_observation,
            obs.cd_ref,
            obs.observateurs,
            obs.dateobs,
            obs.id_dataset,
            tax.patrimonial
        FROM atlas.vm_bib_areas_types AS bat
        JOIN atlas.vm_l_areas AS vla
            ON vla.id_type = bat.id_type
        JOIN atlas.vm_cor_area_synthese AS vcas
            ON vcas.id_area = vla.id_area
        JOIN atlas.vm_observations AS obs
            ON obs.id_observation = vcas.id_synthese
        JOIN atlas.vm_taxons AS tax
            ON tax.cd_ref = obs.cd_ref
        WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    ),

    -- Stats des obs
    stats_obs AS (
        SELECT
            id_area,
            group2_inpn,
            COUNT(DISTINCT id_observation) AS nb_obs,
            COUNT(DISTINCT cd_ref) AS nb_species,
            COUNT(DISTINCT observateurs) AS nb_observers,
            COUNT(DISTINCT cd_ref)
                FILTER (WHERE patrimonial = 'oui')
                AS nb_taxon_patrimonial,
            MIN(EXTRACT(YEAR FROM dateobs)) AS yearmin,
            MAX(EXTRACT(YEAR FROM dateobs)) AS yearmax
        FROM base
        GROUP BY id_area, group2_inpn
    ),

    -- Stats des JDD
    area_group_datasets AS (
        SELECT DISTINCT
            id_area,
            group2_inpn,
            id_dataset
        FROM base
    ),

    -- Stats des organismes
    stats_org AS (
        SELECT
            agd.id_area,
            agd.group2_inpn,
            COUNT(DISTINCT u.id_organisme) AS nb_organism
        FROM area_group_datasets AS agd
        JOIN gn_meta.cor_dataset_actor AS rcda
            ON rcda.id_dataset = agd.id_dataset
        JOIN utilisateurs.bib_organismes AS u
            ON u.id_organisme = rcda.id_organism
        GROUP BY agd.id_area, agd.group2_inpn
    ),

    -- regroupement des taxons
    area_group_taxons AS (
        SELECT DISTINCT
            id_area,
            group2_inpn,
            cd_ref
        FROM base
    ),

    -- Stats des statuts de menace / protection
    stats_statuts AS (
        SELECT
            agt.id_area,
            agt.group2_inpn,
            COUNT(DISTINCT agt.cd_ref)
                FILTER (WHERE cs.statut_menace IS NOT NULL)
                AS nb_taxon_menace,
            COUNT(DISTINCT agt.cd_ref)
                FILTER (WHERE cs.protege IS TRUE)
                AS nb_taxon_protege
        FROM area_group_taxons AS agt
        LEFT JOIN atlas.vm_cor_areas AS ca
            ON ca.id_area = agt.id_area
        LEFT JOIN atlas.vm_cor_taxon_statut_area AS cs
            ON cs.id_area = ca.id_area_parent
        AND cs.cd_ref = agt.cd_ref
        GROUP BY agt.id_area, agt.group2_inpn
    ),

    -- Stats des taxons
    stats_taxons_total AS (
        SELECT
            group2_inpn,
            COUNT(*) AS nb_species_in_teritory
        FROM atlas.vm_taxons
        GROUP BY group2_inpn
    )

    -- Final
    SELECT
        o.id_area,
        o.group2_inpn,
        o.nb_obs,
        o.nb_species,
        o.nb_observers,
        o.nb_taxon_patrimonial,
        o.yearmin,
        o.yearmax,
        COALESCE(g.nb_organism, 0) AS nb_organism,
        COALESCE(s.nb_taxon_menace, 0) AS nb_taxon_menace,
        COALESCE(s.nb_taxon_protege, 0) AS nb_taxon_protege,
        CASE
            WHEN o.group2_inpn IS NULL THEN 0
            ELSE COALESCE(t.nb_species_in_teritory, 0)
        END AS nb_species_in_teritory
    FROM stats_obs AS o
    LEFT JOIN stats_org AS g
        ON g.id_area = o.id_area
    AND g.group2_inpn IS NOT DISTINCT FROM o.group2_inpn
    LEFT JOIN stats_statuts AS s
        ON s.id_area = o.id_area
    AND s.group2_inpn IS NOT DISTINCT FROM o.group2_inpn
    LEFT JOIN stats_taxons_total AS t
        ON t.group2_inpn = o.group2_inpn
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

