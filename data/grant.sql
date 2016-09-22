SET search_path = public, pg_catalog;

--
-- Name: geometry_columns; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE geometry_columns FROM PUBLIC;
REVOKE ALL ON TABLE geometry_columns FROM geonatatlas;
GRANT ALL ON TABLE geometry_columns TO geonatatlas;

--
-- Name: geography_columns; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE geography_columns FROM PUBLIC;
REVOKE ALL ON TABLE geography_columns FROM geonatatlas;
GRANT ALL ON TABLE geography_columns TO geonatatlas;

--
-- Name: spatial_ref_sys; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE spatial_ref_sys FROM PUBLIC;
REVOKE ALL ON TABLE spatial_ref_sys FROM geonatatlas;
GRANT ALL ON TABLE spatial_ref_sys TO geonatatlas;




GRANT USAGE ON SCHEMA atlas TO geonatatlas;


GRANT SELECT ON TABLE atlas.vm_altitudes TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_communes TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_observations TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_cor_taxon_attribut TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_medias TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_observations TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_observations_mailles TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_search_taxon TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_taxons TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_taxons_most_view_temp TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_taxref TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_mois TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_altitudes TO geonatatlas;
GRANT EXECUTE ON FUNCTION atlas.find_all_taxons_childs(integer) TO geonatadmin;