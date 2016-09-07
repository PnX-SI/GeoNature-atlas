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

# last observation for index.html
def lastObservationsMailles(connection, mylimit, idPhoto):
    sql = "SELECT obs.*, \
    tax.lb_nom, tax.nom_vern, tax.group2_inpn, \
    o.dateobs, o.altitude_retenue, \
    medias.url, medias.chemin \
    FROM atlas.vm_observations_mailles obs \
    JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref \
    JOIN atlas.vm_observations o ON o.id_synthese=obs.id_synthese \
    LEFT JOIN atlas.vm_medias medias ON medias.cd_ref = obs.cd_ref AND medias.id_type = 1\
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
                'pathImg' : utils.findPath(o)
                }
        obsList.append(temp)
    return obsList


def lastObservationsCommuneMaille(connection, mylimit, insee):
    sql ="WITH last_obs AS (SELECT obs.cd_ref, obs.dateobs, t.lb_nom, t.nom_vern, st_transform(obs.the_geom_point, 2154) as l_geom \
    FROM atlas.vm_observations obs \
    JOIN layers.l_communes c ON ST_Intersects(st_transform(obs.the_geom_point, 2154), c.the_geom) \
    JOIN atlas.vm_taxons t ON  obs.cd_ref = t.cd_ref \
    WHERE c.insee = :thisInsee \
    ORDER BY obs.dateobs DESC \
    LIMIT :thislimit \
    )\
    SELECT l.lb_nom, l.nom_vern, l.cd_ref, m.id_maille, m.geojson_maille \
    FROM atlas.t_mailles_territoire m \
    JOIN last_obs  l ON st_intersects(l.l_geom, m.geom) \
    GROUP BY l.lb_nom, l.cd_ref, m.id_maille, l.nom_vern"
    observations = connection.execute(text(sql), thisInsee = insee, thislimit=mylimit)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'cd_ref': o.cd_ref,
                'taxon': taxon,
                'geojson_maille':ast.literal_eval(o.geojson_maille),
                'id_maille' : o.id_maille
                }
        obsList.append(temp)
    return obsList



#Use for API
def getObservationsTaxonCommuneMaille(connection, insee, cd_ref):
    sql = "WITH obs_point AS (SELECT st_transform(obs.the_geom_point, 2154) as l_geom, \
     extract(YEAR FROM obs.dateobs) as annee \
    FROM atlas.vm_observations obs \
    JOIN layers.l_communes c ON ST_Intersects(st_transform(obs.the_geom_point, 2154), c.the_geom) \
    JOIN atlas.vm_taxons t ON obs.cd_ref = t.cd_ref \
    WHERE c.insee = :thisInsee AND t.cd_ref = :thiscdref \
    ) \
    SELECT l.annee, m.geojson_maille, m.id_maille \
    FROM atlas.t_mailles_territoire m \
    JOIN obs_point l ON st_intersects(l.l_geom, m.geom) \
    ORDER BY m.id_maille"
    observations = connection.execute(text(sql), thisInsee=insee, thiscdref = cd_ref)
    tabObs = list()
    for o in observations:
        temp = {'id_maille': o.id_maille, 'nb_observations': 1, 'annee': o.annee, 'geojson_maille':ast.literal_eval(o.geojson_maille)}
        tabObs.append(temp)
    return tabObs


