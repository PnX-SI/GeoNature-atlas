-- Tous les taxons ayant au moins une observation
CREATE MATERIALIZED VIEW atlas.vm_taxons AS
    WITH obs_min_taxons AS (
        SELECT
            vm_observations.cd_ref,
            min(date_part('year'::text, vm_observations.dateobs)) AS yearmin,
            max(date_part('year'::text, vm_observations.dateobs)) AS yearmax,
            COUNT(vm_observations.id_observation) AS nb_obs
        FROM atlas.vm_observations
        GROUP BY vm_observations.cd_ref
    ),
    tx_ref AS (
        SELECT
            tx_1.cd_ref,
            tx_1.regne,
            tx_1.phylum,
            tx_1.classe,
            tx_1.ordre,
            tx_1.famille,
            tx_1.cd_taxsup,
            tx_1.lb_nom,
            tx_1.lb_auteur,
            tx_1.nom_complet,
            tx_1.nom_valide,
            tx_1.nom_vern,
            tx_1.nom_vern_eng,
            tx_1.group1_inpn,
            tx_1.group2_inpn,
            tx_1.group3_inpn,
            tx_1.nom_complet_html,
            tx_1.id_rang
        FROM atlas.vm_taxref tx_1
        WHERE tx_1.cd_ref IN (SELECT obs_min_taxons.cd_ref FROM obs_min_taxons)
            AND tx_1.cd_nom = tx_1.cd_ref
    ),
    my_taxons AS (
        SELECT DISTINCT
            n.cd_ref,
            pat.valeur_attribut AS patrimonial
        FROM tx_ref n
            LEFT JOIN taxonomie.cor_taxon_attribut AS pat
                ON (pat.cd_ref = n.cd_ref AND pat.id_attribut = 1)
            JOIN obs_min_taxons obs ON obs.cd_ref = n.cd_ref
    ),
    menace_protege AS (
    SELECT 
        s.cd_ref,
        -- Menacé si au moins un statut de type "menace" est trouvé
        CASE WHEN SUM(CASE WHEN s.code_statut in ('VU', 'EN', 'CR', 'CR*') THEN 1 ELSE 0 END) > 0 
            THEN TRUE ELSE FALSE END AS menace,
        -- Protégé si au moins un statut de type "protection" est trouvé
        CASE WHEN SUM(CASE WHEN s.regroupement_type = 'Protection' THEN 1 ELSE 0 END) > 0 
            THEN TRUE ELSE FALSE END AS protege
    FROM atlas.vm_bdc_statut s
    GROUP BY s.cd_ref
    )
    SELECT
        tx.cd_ref,
        tx.regne,
        tx.phylum,
        tx.classe,
        tx.ordre,
        tx.famille,
        tx.cd_taxsup,
        tx.lb_nom,
        tx.lb_auteur,
        tx.nom_complet,
        tx.nom_valide,
        tx.nom_vern,
        tx.nom_vern_eng,
        tx.group1_inpn,
        tx.group2_inpn,
        tx.group3_inpn,
        tx.nom_complet_html,
        tx.id_rang,
        t.patrimonial,
        -- menace / protege à l'echelle de l'atlas (tous les statut where ENABLE = TRUE)
        -- un taxon peut ensuite ne pas être menacé / protegé au niveau reg
        menace_protege.protege AS protection_stricte,
        menace_protege.menace AS menace,
        omt.yearmin,
        omt.yearmax,
        omt.nb_obs
    FROM tx_ref tx
        LEFT JOIN obs_min_taxons AS omt
            ON omt.cd_ref = tx.cd_ref
        LEFT JOIN my_taxons AS t
            ON t.cd_ref = tx.cd_ref
        LEFT JOIN menace_protege ON menace_protege.cd_ref = tx.cd_ref
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_taxons
    USING btree (cd_ref);
