"""
    FICHIER DE CONFIGURATION A ADAPTER A VOTRE BDD et aux CDREF que vous souhaitez enrichir de medias
"""
SQLALCHEMY_DATABASE_URI = "postgresql://atlasuser:Ubuntu2019@localhost:5432/GN_GBIF"

QUERY_SELECT_CITATION = """SELECT datasetkey, id_synthese from gbif.gbifjam
                        JOIN synthese.syntheseff ON synthese.syntheseff.id_synthese = gbif.gbifjam.gbifid 
                        -- WHERE synthese.syntheseff.observateurs IS NOT NULL
                        ;
 """

# QUERY_SELECT_CDREF = """SELECT DISTINCT cd_ref
#     FROM taxonomie.bib_noms
#     LEFT OUTER JOIN taxonomie.t_medias USING(cd_ref)
#     WHERE id_media IS NULL
#     LIMIT 100
# """

# QUERY_SELECT_CDREF = """SELECT cd_ref from atlas.vm_taxons_plus_observes LIMIT 100"""