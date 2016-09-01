#! /usr/bin/python
# -*- coding:utf-8 -*-

from .. import utils
from sqlalchemy.sql import text
import ast


def getObservationsMaillesChilds(connection, cd_ref):
    sql = "SELECT \
    obs.id_maille, \
    obs.geojson_maille, \
    o.dateobs, \
    extract(YEAR FROM o.dateobs) as annee \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_observations o ON o.id_synthese = obs.id_synthese \
    WHERE obs.cd_ref in (SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) \
    OR obs.cd_ref = :thiscdref \
    ORDER BY id_maille"
    observations = connection.execute(text(sql), thiscdref = cd_ref)
    tabObs = list()
    for o in observations:
        temp = {'id_maille': o.id_maille, 'nb_observations': 1, 'annee': o.annee, 'dateobs': str(o.dateobs), 'geojson_maille':ast.literal_eval(o.geojson_maille)}
        tabObs.append(temp)
    return tabObs


def lastObservationsMailles(connection, mylimit, idPhoto):
    sql = "SELECT obs.*, \
    tax.lb_nom, tax.nom_vern, tax.group2_inpn, \
    o.dateobs, o.altitude_retenue, \
    medias.url \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref \
    JOIN atlas.vm_observations o ON o.id_synthese=obs.id_synthese \
    LEFT JOIN atlas.vm_medias medias ON medias.cd_ref = obs.cd_ref AND medias.id_media = 1\
    ORDER BY o.dateobs DESC \
    LIMIT :thislimit "

    observations = connection.execute(text(sql), thislimit = mylimit)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            inter = o.nom_vern.split(',')
            taxon = inter[0] +' | '+ o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_synthese' : o.id_synthese,
                'id_maille' : o.id_maille,
                'cd_ref': o.cd_ref,
                'dateobs': str(o.dateobs),
                'altitude_retenue' : o.altitude_retenue,
                'taxon': taxon,
                'geojson_maille':ast.literal_eval(o.geojson_maille),
                'group2_inpn': utils.deleteAccent(o.group2_inpn),
                'urlImage' : o.url
                }
        obsList.append(temp)
    return obsList

def lastObservationsCommuneMaille(connection, mylimit, insee):
    sql = "SELECT obs.id_synthese, o.cd_ref, obs.dateobs, t.lb_nom, t.nom_vern, o.geojson_maille, o.id_maille \
    FROM atlas.vm_observations_mailles o \
    JOIN layers.l_communes c ON ST_Intersects(o.geom, c.the_geom) \
    JOIN atlas.vm_observations obs ON obs.id_synthese = o.id_synthese \
    JOIN atlas.vm_taxons t ON  o.cd_ref = t.cd_ref \
    WHERE c.insee = :thisInsee \
    ORDER BY obs.dateobs DESC \
    LIMIT 100"
    observations = connection.execute(text(sql), thisInsee = insee)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_synthese' : o.id_synthese,
                'cd_ref': o.cd_ref,
                'dateobs': str(o.dateobs),
                'taxon': taxon,
                'geojson_maille':ast.literal_eval(o.geojson_maille),
                'id_maille' : o.id_maille
                }
        obsList.append(temp)
    return obsList


def getObservationsTaxonCommuneMaille(connection, insee, cd_ref):
    sql ="SELECT \
        obs.id_maille, \
        obs.geojson_maille, \
        o.dateobs, \
        extract(YEAR FROM o.dateobs) as annee \
        FROM atlas.vm_observations_mailles obs \
        JOIN atlas.vm_communes c ON ST_intersects (c.the_geom, obs.geom) \
        JOIN atlas.vm_observations o ON o.id_synthese = obs.id_synthese \
        WHERE obs.cd_ref = :thiscdref  AND c.insee = :thisInsee \
        ORDER BY obs.id_maille"
    observations = connection.execute(text(sql), thisInsee=insee, thiscdref = cd_ref)
    tabObs = list()
    for o in observations:
        temp = {'id_maille': o.id_maille, 'nb_observations': 1, 'annee': o.annee, 'dateobs': str(o.dateobs), 'geojson_maille':ast.literal_eval(o.geojson_maille)}
        tabObs.append(temp)
    return tabObs