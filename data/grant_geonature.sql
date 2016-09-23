-- Affectation des droits en lecture sur la base mere GeoNature
GRANT USAGE ON SCHEMA synthese TO myuser;
GRANT USAGE ON SCHEMA taxonomie TO myuser;
GRANT USAGE ON SCHEMA layers TO myuser;
GRANT USAGE ON SCHEMA public TO myuser;


GRANT SELECT ON TABLE synthese.syntheseff TO myuser;

GRANT SELECT ON TABLE taxonomie.cor_taxon_attribut TO myuser;
GRANT SELECT ON TABLE taxonomie.taxref TO myuser;
GRANT SELECT ON TABLE taxonomie.t_medias TO myuser;


GRANT SELECT ON TABLE layers.l_communes TO myuser;



