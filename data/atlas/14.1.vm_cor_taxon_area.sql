CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_area AS
    SELECT DISTINCT
        obs.cd_ref,
        cas.id_area
    FROM atlas.vm_observations AS obs
        JOIN atlas.vm_cor_area_synthese AS cas
            ON cas.id_synthese = obs.id_observation
    WHERE cas.is_valid_for_display IS TRUE;

CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_area
    USING btree (cd_ref, id_area);
