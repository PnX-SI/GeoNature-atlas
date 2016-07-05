from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from tCommunes import LCommune
from sqlalchemy import distinct
from vmObservations import VmObservations
from sqlalchemy.orm import sessionmaker
session = manage.loadSession()



def getCommuneFromInsee(insee):
    req =  session.query(LCommune.commune_maj).filter(LCommune.insee==insee).all()
    return req[0].commune_maj


def getAllCommune():
    req = session.query(distinct(LCommune.commune_maj), LCommune.insee).join(VmObservations, VmObservations.insee==LCommune.insee).all()
    communeList = list()
    for r in req:
        temp = { 'label' : r[0], 'value' : r[1]}
        communeList.append(temp)
    return communeList
