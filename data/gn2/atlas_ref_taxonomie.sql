
--TAXONOMIE
--################################
--  Import FDW
--################################

CREATE SCHEMA IF NOT EXISTS taxonomie;

IMPORT FOREIGN SCHEMA taxonomie
LIMIT TO (taxonomie.taxref, taxonomie.cor_taxon_attribut, taxonomie.t_medias)
FROM SERVER geonaturedbserver INTO taxonomie ;
