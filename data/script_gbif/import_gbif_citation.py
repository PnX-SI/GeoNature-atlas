# coding: utf8


'''
    Script permettant l'import de sources récupérées via l'API GBIF
'''
import requests 
import psycopg2


import config

# ################
# CONSTANTES
API_URL = "http://api.gbif.org/v1/dataset/{}"

SOURCE = "GBIF"

QUERY_UPDATE_SOURCES = """
    update synthese.syntheseff 
    SET observateurs = %s
    WHERE id_synthese = %s
"""
class Source():

    def __init__(
        self, 
        source
    ):
        self.source = source

    def __repr__(self):
        return "source: {}".format(
            self.source
        )

# ################
# FONCTIONS

def runquery(cursor, sql, params, trap=False):
    '''
        Fonction permettant d'executer une requete
        trap : Indique si les erreurs sont ou pas retournées
    '''
    try:
        result = cursor.execute(
            sql,
            params
        )
        return result
    except Exception as exp:
        print(exp)
        if trap:
            return None
        raise exp


def process_source(cur, id_synthese, source, trap=False):
    '''
        Fonction qui gère l'enregistrement de la source
        dans la base
    '''
    # s_obj = Source(
    #     source = source
    # )

    try:
        result = cursor.execute(
            QUERY_UPDATE_SOURCES,
            (source, id_synthese)
        )
        return result
    except Exception as exp:
        print(exp)
        if trap:
            return None
        raise exp

    print('update')
    # runquery(
    #     cur,
    #     QUERY_UPDATE_SOURCES,
    #     (
    #         s_obj.source,
    #         id_synthese
    #     ),
    #     True
    # )
    DB_CONNEXION.commit()


# ################
# SCRIPT
try:
    DB_CONNEXION = psycopg2.connect(config.SQLALCHEMY_DATABASE_URI)
    print('connexion ok')
except Exception as exp:
    print("Connexion à la base impossible")
    quit()

try:
    cursor = DB_CONNEXION.cursor()
    rows = runquery(cursor, config.QUERY_SELECT_CITATION, None, False)
    rows = cursor.fetchall()
except Exception as exp:
    print("Problème lors de la récupération de la liste des id_synthese")
    quit()


for r in rows:
    url = API_URL.format(r[0])
    print(r[0])
    print(r[1])
    req = None
    try:
        req = requests.get(url)
    except Exception as e:
        print(e) 
    if req and req.status_code == 200 :
        data = req.json()
        if 'citation' in data:
            process_source(cursor, r[1], data['citation']['text'], True)
        else:
            print (" Pas de source pour cette occurence ")


DB_CONNEXION.close()
