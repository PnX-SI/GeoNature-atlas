#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import manage 
from modeles import utils
from sqlalchemy.sql import text
import ast

session = manage.loadSession()
connection = manage.engine.connect()



def getObservationsMaillesChilds(cd_ref):
    sql = "select \
    obs.id_maille, \
    obs.geojson_maille, \
    sum(obs.nb_observations) as nb_observations, \
    extract(YEAR FROM o.dateobs) as annee \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_observations o ON o.id_synthese = obs.id_synthese \
    WHERE obs.cd_ref in (SELECT * FROM atlas.find_all_taxons_childs(61714)) \
    OR obs.cd_ref = 61714 \
    GROUP BY o.dateobs, obs.nb_observations, obs.id_maille, obs.geojson_maille \
    ORDER BY id_maille"
    observations = connection.execute(text(sql), thiscdref = cd_ref)
    tabObs = list()
    for o in observations:
        temp = {'id_maille': o.id_maille, 'nb_observations': int(o.nb_observations), 'annee': o.annee, 'geojson_maille':  ast.literal_eval(o.geojson_maille)}
        tabObs.append(temp)
    return tabObs
