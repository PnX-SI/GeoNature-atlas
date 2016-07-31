#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import manage 
from modeles import utils
from sqlalchemy.sql import text
import ast


def getObservationsMaillesChilds(connection, cd_ref):
    sql = "SELECT \
    obs.id_maille, \
    obs.geojson_maille, \
    count(obs.id_synthese) as nb_observations, \
    extract(YEAR FROM o.dateobs) as annee \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_observations o ON o.id_synthese = obs.id_synthese \
    WHERE obs.cd_ref in (SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) \
    OR obs.cd_ref = :thiscdref \
    GROUP BY o.dateobs, obs.id_maille, obs.geojson_maille \
    ORDER BY id_maille"
    observations = connection.execute(text(sql), thiscdref = cd_ref)
    tabObs = list()
    for o in observations:
        temp = {'id_maille': o.id_maille, 'nb_observations': int(o.nb_observations), 'annee': o.annee, 'geojson_maille':  ast.literal_eval(o.geojson_maille)}
        tabObs.append(temp)
    return tabObs

def lastObservationsMailles(connection, mylimit):
    sql = "SELECT \
    obs.id_maille, \
    obs.id_synthese, \
    obs.geojson_maille, \
    o.dateobs , \
    o.cd_ref, \
    t.lb_nom, \
    t.nom_vern \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_observations o ON o.id_synthese = obs.id_synthese \
    JOIN atlas.vm_taxons t ON o.cd_ref = t.cd_ref \
    ORDER BY o.dateobs DESC \
    LIMIT :thisLimit"
    observations = connection.execute(text(sql), thisLimit = mylimit)
    tabObs = list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_maille': o.id_maille, 'cd_ref': o.cd_ref, 'taxon': taxon, 'geojson_maille': ast.literal_eval(o.geojson_maille), 'id_synthese': o.id_synthese}
        tabObs.append(temp)
    return tabObs
