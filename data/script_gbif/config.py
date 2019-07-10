"""
    FICHIER DE CONFIGURATION A ADAPTER A VOTRE BDD et aux CDREF que vous souhaitez enrichir de medias
"""
SQLALCHEMY_DATABASE_URI = "postgresql://geonatusercp:monpassachanger@localhost:5432/geonatureatlascp"

QUERY_SELECT_CITATION = """SELECT "datasetKey", id_synthese 
                          FROM gbif.gbifjam
                          JOIN synthese.syntheseff ON synthese.syntheseff.id_synthese = gbif.gbifjam."gbifID" 
                          WHERE synthese.syntheseff.observateurs IS NULL
                        ;
 """

QUERY_SELECT_CDREF = """SELECT DISTINCT cd_ref
     FROM taxonomie.bib_noms
     LEFT OUTER JOIN taxonomie.t_medias USING(cd_ref)
     WHERE id_media IS NULL
"""

# QUERY_SELECT_CDREF = """SELECT cd_ref from atlas.vm_taxons_plus_observes LIMIT 100"""
