CREATE MATERIALIZED VIEW atlas.vm_observations_meshes_agg AS
    SELECT obs.cd_ref,
        obs.id_maille AS id_mesh,
        obs.annee AS "year",
        COUNT(obs.id_observation) AS nbr
    FROM atlas.vm_observations_mailles AS obs
    GROUP BY obs.cd_ref, obs.id_maille, obs.annee
    ORDER BY obs.cd_ref, obs.annee
WITH DATA;

-- View indexes:
CREATE INDEX idx_voma_annee ON atlas.vm_observations_meshes_agg
    USING btree ("year");
CREATE INDEX idx_voma_id_maille_cd_ref ON atlas.vm_observations_meshes_agg
    USING btree (id_mesh, cd_ref);
