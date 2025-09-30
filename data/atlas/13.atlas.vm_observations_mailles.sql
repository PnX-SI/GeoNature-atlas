CREATE MATERIALIZED VIEW atlas.vm_cor_maille_observation
TABLESPACE pg_default
AS SELECT o_1.id_observation,
    cas.id_area AS id_maille,
    cas.type_code
   FROM atlas.vm_observations o_1
     JOIN atlas.vm_cor_area_synthese cas ON cas.id_synthese = o_1.id_observation
     JOIN atlas.cor_sensitivity_area_type csat ON o_1.cd_sensitivity::text = csat.sensitivity_code::text AND cas.type_code::text = csat.area_type_code::text
WITH DATA;

-- View indexes:
CREATE INDEX vm_cor_maille_observation_id_maille_idx ON atlas.vm_cor_maille_observation USING btree (id_maille);
CREATE INDEX vm_cor_maille_observation_id_observation_idx ON atlas.vm_cor_maille_observation USING btree (id_observation);