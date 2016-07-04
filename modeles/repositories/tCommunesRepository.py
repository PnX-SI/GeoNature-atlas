from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from tCommunes import LCommune
from sqlalchemy.orm import sessionmaker
session = manage.loadSession()



def getCommuneFromInsee(insee):
    req =  session.query(LCommune.commune_maj).filter(LCommune.insee==insee).all()
    return req[0]