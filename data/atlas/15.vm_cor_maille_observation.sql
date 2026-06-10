-- Cette VM permet de stocker la maille d'affichage (floutée ou non) d'une observation, quand on les affiche au niveau Maille.
-- C'est une selection d'un seul zonage par observation, basée sur gn_synthese.cor_area_synthese

CREATE MATERIALIZED VIEW atlas.vm_cor_maille_observation AS
    SELECT
        cas.id_area AS id_maille,
        cas.type_code,
        o.id_observation
    FROM atlas.vm_observations AS o
        JOIN atlas.vm_cor_area_synthese AS cas
            ON cas.id_synthese = o.id_observation
        JOIN atlas.vm_cor_sensitivity_area_type AS csat
            ON (
                o.cd_sensitivity = csat.sensitivity_code
                AND cas.type_code = csat.area_type_code
            )
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_maille_observation
    USING btree (id_maille, id_observation);

CREATE INDEX ON atlas.vm_cor_maille_observation
    USING btree (id_observation);
