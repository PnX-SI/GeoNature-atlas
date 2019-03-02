
# -*- coding:utf-8 -*-

from .. import utils
from sqlalchemy.sql import text
import ast


def getObservationsMaillesChilds(connection, cd_ref):
    sql = """SELECT
            obs.id_maille,
            obs.geojson_maille,
            o.dateobs,
            extract(YEAR FROM o.dateobs) as annee
        FROM atlas.vm_observations_mailles obs
        JOIN atlas.vm_observations o ON o.id_observation = obs.id_observation
        WHERE obs.cd_ref in (
                SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
            )
            OR obs.cd_ref = :thiscdref
        ORDER BY id_maille"""
    observations = connection.execute(text(sql), thiscdref=cd_ref)
    tabObs = list()
    for o in observations:
        temp = {
            'id_maille': o.id_maille,
            'nb_observations': 1,
            'annee': o.annee,
            'dateobs': str(o.dateobs),
            'geojson_maille': ast.literal_eval(o.geojson_maille)
        }
        tabObs.append(temp)
    return tabObs

#Maille avec date de derniere obs seulement
def getObservationsMaillesLastObsChilds(connection, cd_ref):
    sql = """
        SELECT
            obs.id_maille,
            obs.geojson_maille,
            max(date_part('year', o.dateobs)) as lastyear
        FROM atlas.vm_observations_mailles obs
        JOIN atlas.vm_observations o ON o.id_observation = obs.id_observation
        WHERE obs.cd_ref in (
                SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
            )
            OR obs.cd_ref = :thiscdref
	GROUP BY obs.id_maille, obs.geojson_maille
        ORDER BY id_maille"""
    observations = connection.execute(text(sql), thiscdref=cd_ref)
    tabObs = list()
    for o in observations:
        temp = {
            'properties':{
            'id_maille': o.id_maille,
            'nb_observations': 1,
            'lastyear': o.lastyear},
            'geometry': ast.literal_eval(o.geojson_maille),
            'type' : "Feature"
        }
        tabObs.append(temp)
    outGeoJson={'type':"FeatureCollection", 'features':tabObs}
    return outGeoJson


# last observation for index.html
def lastObservationsMailles(connection, mylimit, idPhoto):
    sql = """
        SELECT obs.*,
        tax.lb_nom, tax.nom_vern, tax.group2_inpn,
        o.dateobs, o.altitude_retenue,
        medias.url, medias.chemin, medias.id_media
        FROM atlas.vm_observations_mailles obs
        JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref
        JOIN atlas.vm_observations o ON o.id_observation=obs.id_observation
        LEFT JOIN atlas.vm_medias medias
            ON medias.cd_ref = obs.cd_ref AND medias.id_type = :thisID
        WHERE  o.dateobs >= (CURRENT_TIMESTAMP - INTERVAL :thislimit)
        ORDER BY o.dateobs DESC
    """

    observations = connection.execute(
        text(sql),
        thislimit=mylimit,
        thisID=idPhoto
    )
    obsList = list()
    for o in observations:
        if o.nom_vern:
            inter = o.nom_vern.split(',')
            taxon = inter[0] + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {
            'id_observation': o.id_observation,
            'id_maille': o.id_maille,
            'cd_ref': o.cd_ref,
            'dateobs': str(o.dateobs),
            'altitude_retenue': o.altitude_retenue,
            'taxon': taxon,
            'geojson_maille': ast.literal_eval(o.geojson_maille),
            'group2_inpn': utils.deleteAccent(o.group2_inpn),
            'pathImg': utils.findPath(o),
            'id_media': o.id_media
        }
        obsList.append(temp)
    return obsList


def lastObservationsCommuneMaille(connection, mylimit, insee):
    sql = """
    WITH last_obs AS (
        SELECT
            obs.cd_ref, obs.dateobs, t.lb_nom,
            t.nom_vern, obs.the_geom_point as l_geom
        FROM atlas.vm_observations obs
        JOIN atlas.vm_communes c
        ON ST_Intersects(obs.the_geom_point, c.the_geom)
        JOIN atlas.vm_taxons t
        ON  obs.cd_ref = t.cd_ref
        WHERE c.insee = :thisInsee
        ORDER BY obs.dateobs DESC
        LIMIT :thislimit
    )
    SELECT l.lb_nom, l.nom_vern, l.cd_ref, m.id_maille, m.geojson_maille
    FROM atlas.t_mailles_territoire m
    JOIN last_obs  l
    ON st_intersects(l.l_geom, m.the_geom)
    GROUP BY l.lb_nom, l.cd_ref, m.id_maille, l.nom_vern
    """
    observations = connection.execute(
        text(sql), thisInsee=insee, thislimit=mylimit
    )
    obsList = list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {
            'cd_ref': o.cd_ref,
            'taxon': taxon,
            'geojson_maille': ast.literal_eval(o.geojson_maille),
            'id_maille': o.id_maille
        }
        obsList.append(temp)
    return obsList


# Use for API
def getObservationsTaxonCommuneMaille(connection, insee, cd_ref):
    sql = """
        SELECT
            o.cd_ref, t.id_maille, t.geojson_maille,
            extract(YEAR FROM o.dateobs) as annee
        FROM atlas.vm_observations o
        JOIN atlas.vm_communes c
        ON ST_INTERSECTS(o.the_geom_point, c.the_geom)
        JOIN atlas.t_mailles_territoire t
        ON ST_INTERSECTS(t.the_geom, o.the_geom_point)
        WHERE o.cd_ref = :thiscdref AND c.insee = :thisInsee
        ORDER BY id_maille
    """
    observations = connection.execute(
        text(sql), thisInsee=insee, thiscdref=cd_ref
    )
    tabObs = list()
    for o in observations:
        temp = {
            'id_maille': o.id_maille,
            'nb_observations': 1,
            'annee': o.annee,
            'geojson_maille': ast.literal_eval(o.geojson_maille)
        }
        tabObs.append(temp)

    return tabObs
