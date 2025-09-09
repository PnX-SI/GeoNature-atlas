DROP MATERIALIZED VIEW IF EXISTS atlas.vm_taxons_areas;
CREATE MATERIALIZED VIEW atlas.vm_taxons_areas AS
WITH obs_area as (
	SELECT DISTINCT ON (vca.id_area, vmo.id_observation)
	    vca.id_area,
	    vmo.id_observation,
		vmo.id_dataset,
	    vmo.cd_ref,
	    vmo.dateobs,
	    vmo.observateurs,
		vca.type_code
	FROM atlas.vm_cor_area_synthese vca
	JOIN atlas.vm_observations vmo ON vmo.id_observation = vca.id_synthese
	), obs_area_statut as (
		SELECT obs_area.*,
			 st.code_statut,
			 st.cd_type_statut,
			 st.cd_sig,
			 st.code_statut in ('VU', 'CR', 'EN') as threatened
		FROM obs_area
		LEFT OUTER JOIN atlas.vm_bdc_statut st on st.cd_ref = obs_area.cd_ref	
	) 
	SELECT ROW_NUMBER() OVER() as id, * FROM obs_area_statut; 

CREATE INDEX idx_vm_taxons_areas_cd_ref ON atlas.vm_taxons_areas(cd_ref);
CREATE INDEX idx_vm_taxons_areas_id_area ON atlas.vm_taxons_areas(id_area);
CREATE INDEX idx_vm_taxons_areas_id_obs ON atlas.vm_taxons_areas(id_observation);
CREATE INDEX idx_vm_taxons_areas_id_data ON atlas.vm_taxons_areas(id_dataset);
