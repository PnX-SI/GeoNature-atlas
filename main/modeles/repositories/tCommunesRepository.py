#! /usr/bin/python
# -*- coding:utf-8 -*-
import ast
from ..entities.tCommunes import LCommune
from sqlalchemy import distinct
from ..entities.vmObservations import VmObservations
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import text
import ast



def getAllCommune(session):
    req = session.query(distinct(LCommune.commune_maj), LCommune.insee).join(VmObservations, VmObservations.insee==LCommune.insee).all()
    communeList = list()
    for r in req:
        temp = { 'label' : r[0], 'value' : r[1]}
        communeList.append(temp)
    return communeList



def getCommuneFromInsee(connection, insee):
    sql = "SELECT l.commune_maj, l.insee, \
           st_asgeojson(st_transform(l.the_geom, 4326)) as commune_geojson \
           FROM layers.l_communes l \
           WHERE l.insee = :thisInsee"
    req = connection.execute(text(sql), thisInsee = insee)
    communeObj = dict()
    for r in req:
        communeObj = {'communeName': r.commune_maj, 'insee': r.insee, 'communeGeoJson' : ast.literal_eval(r.commune_geojson)}
    return communeObj


    return req[0].commune_maj

def getCommunesObservations(cd_ref):
    return session.query(distinct(VmObservations.insee), VmObservations.insee, LCommune.commune_maj)\
    .join(LCommune, VmObservations.insee == LCommune.insee).group_by(VmObservations.insee, LCommune.commune_min, LCommune.commune_maj)\
    .filter(VmObservations.cd_ref==cd_ref).all()


def getCommunesObservationsChilds(connection, cd_ref):
    sql = "select distinct(com.insee) as insee \
    , com.commune_maj \
    FROM layers.l_communes com \
    JOIN atlas.vm_observations obs ON obs.insee = com.insee \
    WHERE obs.cd_ref in ( \
    SELECT * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR obs.cd_ref = :thiscdref \
    GROUP BY com.commune_maj, com.insee".encode('UTF-8')

    return connection.execute(text(sql), thiscdref = cd_ref)