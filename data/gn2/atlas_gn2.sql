-- Création en FDW des tables ref_nomenclature et schéma ref_geo

IMPORT FOREIGN SCHEMA ref_nomenclatures
LIMIT TO (ref_nomenclatures.t_nomenclatures, ref_nomenclatures.bib_nomenclatures_types)
FROM SERVER geonaturedbserver INTO synthese;

DROP SCHEMA IF EXISTS ref_geo CASCADE;
CREATE SCHEMA IF NOT EXISTS ref_geo;
IMPORT FOREIGN SCHEMA ref_geo
LIMIT TO (ref_geo.l_areas, ref_geo.li_municipalities, ref_geo.bib_areas_types, ref_geo.cor_areas)
FROM SERVER geonaturedbserver INTO ref_geo;

IMPORT FOREIGN SCHEMA gn_synthese
LIMIT TO (gn_synthese.synthese, gn_synthese.cor_area_synthese)
FROM SERVER geonaturedbserver INTO synthese;

IMPORT FOREIGN SCHEMA gn_sensitivity
LIMIT TO (cor_sensitivity_area_type)
FROM SERVER geonaturedbserver INTO synthese;

-- Schéma utilisateurs necessaire pour ajouter la dimension organisme à l'atlas
IMPORT FOREIGN SCHEMA utilisateurs
LIMIT TO (utilisateurs.bib_organismes)
FROM SERVER geonaturedbserver INTO utilisateurs;

IMPORT FOREIGN SCHEMA gn_meta
LIMIT TO (gn_meta.cor_dataset_actor)
FROM SERVER geonaturedbserver INTO gn_meta;
