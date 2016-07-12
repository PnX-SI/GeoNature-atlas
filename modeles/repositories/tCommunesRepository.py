from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from tCommunes import LCommune
from sqlalchemy import distinct
from vmObservations import VmObservations
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import text


session = manage.loadSession()
connection = manage.engine.connect()



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

def getCommunesObservations(cd_ref):
    return session.query(distinct(VmObservations.insee), VmObservations.insee, LCommune.commune_maj)\
    .join(LCommune, VmObservations.insee == LCommune.insee).group_by(VmObservations.insee, LCommune.commune_min, LCommune.commune_maj)\
    .filter(VmObservations.cd_ref==cd_ref).all()


def getCommunesObservationsChilds(cd_ref):
    sql = "select distinct(com.insee) as insee \
    , com.commune_maj \
    FROM layers.l_communes com \
    JOIN atlas.vm_observations obs ON obs.insee = com.insee \
    WHERE obs.cd_ref in ( \
    SELECT * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR obs.cd_ref = :thiscdref \
    GROUP BY com.commune_maj, com.insee".encode('UTF-8')

    return connection.execute(text(sql), thiscdref = cd_ref)