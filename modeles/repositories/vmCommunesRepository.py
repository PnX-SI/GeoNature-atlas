from atlas import APP_DIR, BASE_DIR, manage
import sys
import ast
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmCommunes import VmCommunes
from sqlalchemy import distinct
from vmObservations import VmObservations
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import text
import ast




def getAllCommunes(session):
    req = session.query(distinct(VmCommunes.commune_maj), VmCommunes.insee).all()
    communeList = list()
    for r in req:
        temp = { 'label' : r[0], 'value' : r[1]}
        communeList.append(temp)
    return communeList



def getCommuneFromInsee(connection, insee):
    sql = "SELECT c.commune_maj, \
           c.commune_geojson \
           FROM atlas.vm_communes c \
           WHERE c.insee = :thisInsee"
    req = connection.execute(text(sql), thisInsee = insee)
    communeObj = dict()
    for r in req:
        communeObj = {'communeName': r.commune_maj, 'communeGeoJson' : ast.literal_eval(r.commune_geojson)}
    return communeObj


    return req[0].commune_maj

def getCommunesObservations(cd_ref):
    return session.query(distinct(VmObservations.insee), VmObservations.insee, VmCommunes.commune_maj)\
    .join(VmCommunes, VmObservations.insee == VmCommunes.insee).group_by(VmObservations.insee, VmCommunes.commune_min, VmCommunes.commune_maj)\
    .filter(VmObservations.cd_ref==cd_ref).all()


def getCommunesObservationsChilds(connection, cd_ref):
    sql = "select distinct(com.insee) as insee \
    , com.commune_maj \
    FROM atlas.vm_communes com \
    JOIN atlas.vm_observations obs ON obs.insee = com.insee \
    WHERE obs.cd_ref in ( \
    SELECT * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR obs.cd_ref = :thiscdref \
    GROUP BY com.commune_maj, com.insee".encode('UTF-8')

    return connection.execute(text(sql), thiscdref = cd_ref)