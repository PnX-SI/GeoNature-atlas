-- Création en FDW des tables ref_nomenclature et schéma ref_geo

IMPORT FOREIGN SCHEMA ref_nomenclatures
	LIMIT TO (ref_nomenclatures.t_nomenclatures, ref_nomenclatures.bib_nomenclatures_types)
    FROM SERVER geonaturedbserver INTO synthese;

-- schéma ref_geo necessaire pour créé la vue syntheseff qui s'appuye sur le ref_geo pour la sensibilité
DROP SCHEMA IF EXISTS ref_geo CASCADE;
CREATE SCHEMA IF NOT EXISTS ref_geo;

IMPORT FOREIGN SCHEMA ref_geo
LIMIT TO (ref_geo.l_areas, ref_geo.li_municipalities, ref_geo.bib_areas_types)
FROM SERVER geonaturedbserver INTO ref_geo ;