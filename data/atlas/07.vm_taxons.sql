-- Tous les taxons ayant au moins une observation
CREATE MATERIALIZED VIEW atlas.vm_taxons AS
    WITH observations_stats AS (
        SELECT
            cd_ref,
            min(date_part('year'::text, dateobs)) AS yearmin,
            max(date_part('year'::text, dateobs)) AS yearmax,
            count(id_observation) AS nb_obs
        FROM atlas.vm_observations
        GROUP BY cd_ref
    ),
    taxons_infos AS (
        SELECT
            cd_ref,
            regne,
            phylum,
            classe,
            ordre,
            famille,
            cd_taxsup,
            lb_nom,
            lb_auteur,
            nom_complet,
            nom_valide,
            nom_vern,
            nom_vern_eng,
            group1_inpn,
            group2_inpn,
            nom_complet_html,
            id_rang
        FROM atlas.vm_taxref
        WHERE cd_ref IN (SELECT cd_ref FROM observations_stats)
            AND cd_nom = cd_ref
    ),
    taxons_attributes AS (
        SELECT DISTINCT
            ti.cd_ref,
            pat.valeur_attribut AS patrimonial
        FROM taxons_infos AS ti
            LEFT JOIN taxonomie.cor_taxon_attribut AS pat
                ON (pat.cd_ref = ti.cd_ref AND pat.id_attribut = 1)
            JOIN observations_stats AS os ON os.cd_ref = ti.cd_ref
    ),
    threat_protection_status AS (
        SELECT
            cd_ref,
            -- Menacé si au moins un statut de type "menace" est trouvé
            CASE WHEN SUM(CASE WHEN code_statut in ('VU', 'EN', 'CR', 'CR*') THEN 1 ELSE 0 END) > 0
                THEN TRUE
                ELSE FALSE
            END AS threat,
            -- Protégé si au moins un statut de type "protection" est trouvé
            CASE WHEN SUM(CASE WHEN regroupement_type = 'Protection' THEN 1 ELSE 0 END) > 0
                THEN TRUE
                ELSE FALSE
            END AS protection
        FROM atlas.vm_bdc_statut
        GROUP BY cd_ref
    )
    SELECT
        ti.cd_ref,
        ti.regne,
        ti.phylum,
        ti.classe,
        ti.ordre,
        ti.famille,
        ti.cd_taxsup,
        ti.lb_nom,
        ti.lb_auteur,
        ti.nom_complet,
        ti.nom_valide,
        ti.nom_vern,
        ti.nom_vern_eng,
        ti.group1_inpn,
        ti.group2_inpn,
        ti.nom_complet_html,
        ti.id_rang,
        ta.patrimonial,
        tps.protection AS protection_stricte,
        tps.threat AS menace,
        os.yearmin,
        os.yearmax,
        os.nb_obs
    FROM taxons_infos AS ti
        LEFT JOIN observations_stats AS os
            ON os.cd_ref = ti.cd_ref
        LEFT JOIN taxons_attributes AS ta
            ON ta.cd_ref = ti.cd_ref
        LEFT JOIN threat_protection_status AS tps
            ON tps.cd_ref = ti.cd_ref
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_taxons
    USING btree (cd_ref);
