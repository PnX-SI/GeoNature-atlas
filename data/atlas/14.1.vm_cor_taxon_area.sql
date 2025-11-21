CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_area AS
    WITH taxons AS (
        SELECT
            cd_ref,
            array_agg(id_observation) AS observations
        FROM atlas.vm_observations
        GROUP BY cd_ref
    )
    SELECT DISTINCT
        t.cd_ref,
        cas.id_area
    FROM taxons AS t
        JOIN atlas.vm_cor_area_synthese AS cas
            ON cas.id_synthese = ANY(t.observations)
    WHERE cas.is_valid_for_display IS TRUE ;

CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_area
    USING btree (cd_ref, id_area);
