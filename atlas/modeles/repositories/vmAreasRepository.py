# -*- coding:utf-8 -*-

import ast
import json
from datetime import datetime

from flask import current_app
from geojson import Feature, FeatureCollection
from sqlalchemy import or_, and_, case
from sqlalchemy.sql.expression import func

from atlas.modeles import utils
from atlas.modeles.entities.tGrid import TGrid
from atlas.modeles.entities.vmAreas import (
    VmAreas,
    VmCorAreaObservation,
    VmBibAreasTypes,
)
from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmTaxref import VmTaxref


def filter_by_type_codes(query, type_codes = []):
    if len(type_codes) > 0:
        query = query.filter(VmBibAreasTypes.type_code.in_(type_codes))
    return query


def get_area_from_id(session, id_area):
    """
    Get area info from an id
    """
    query = (
        session.query(
            VmAreas.id_area,
            VmAreas.area_name, 
            VmAreas.area_code, 
            VmAreas.area_geojson, 
            VmBibAreasTypes.type_name)
        .filter(VmAreas.id_area==id_area)
        .join(VmBibAreasTypes, VmBibAreasTypes.id_type == VmAreas.id_type))

    result = query.first()
    return {
            "areaId": result.id_area,
            "areaName": result.area_name,
            "areaCode": str(result.area_code),
            "areaGeoJson": json.loads(result.area_geojson),
            "typeName": result.type_name
        }


def last_observations_area_maille(session, myLimit, idArea):
    """
    Gets the last observations for a specific area
    """
    q_last_obs = (
        session.query(
            VmObservations.cd_ref,
            VmObservations.dateobs,
            VmTaxons.lb_nom,
            VmTaxons.nom_vern,
            VmObservations.the_geom_point,
        )
        .join(
            VmCorAreaObservation,
            VmObservations.id_observation == VmCorAreaObservation.id_observation,
        )
        .join(VmAreas, VmAreas.id_area == VmCorAreaObservation.id_area)
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .filter(VmAreas.id_area == idArea)
        .order_by(VmObservations.dateobs.desc())
        .limit(myLimit)
        .subquery()
    )
    current_app.logger.debug(
        "<last_observations_area_maille> subquery q_last_obs: {}".format(q_last_obs)
    )

    q_mailles_obs = (
        session.query(
            TGrid.id_maille,
            q_last_obs.c.lb_nom,
            q_last_obs.c.cd_ref,
            q_last_obs.c.nom_vern,
            func.st_asgeojson(TGrid.the_geom).label(
                "geojson_maille"
            ),
        )
        .join(q_last_obs, q_last_obs.c.the_geom_point.st_intersects(TGrid.the_geom))
        .group_by(
            q_last_obs.c.lb_nom,
            q_last_obs.c.cd_ref,
            q_last_obs.c.nom_vern,
            TGrid.id_maille,
            TGrid.the_geom,
        )
    )

    current_app.logger.debug(
        "<last_observations_area_maille> query q_mailles_obs: {}".format(q_mailles_obs)
    )
    current_app.logger.debug(
        "<last_observations_area_maille> start query: {}".format(datetime.now())
    )
    result = q_mailles_obs.all()
    current_app.logger.debug(
        "<last_observations_area_maille> start loop: {}".format(datetime.now())
    )
    obsList = list()
    for o in result:
        if o.nom_vern:
            taxon = o.nom_vern + " | " + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {
            "cd_ref": o.cd_ref,
            "taxon": taxon,
            "geojson_maille": json.loads(o.geojson_maille),
            "id_maille": o.id_maille,
        }
        obsList.append(temp)
    current_app.logger.debug(
        "<last_observations_area_maille> end loop: {}".format(datetime.now())
    )
    return obsList


def get_observers_area(session, id_area):
    q_list_observers = (
        session.query(
            func.trim(
                func.unnest(func.string_to_array(VmObservations.observateurs, ","))
            ).label("observateurs")
        )
        .join(
            VmCorAreaObservation,
            VmObservations.id_observation == VmCorAreaObservation.id_observation,
        )
        .filter(VmCorAreaObservation.id_area == id_area)
    ).subquery()

    query = session.query(q_list_observers.c.observateurs).group_by(
        q_list_observers.c.observateurs
    )
    return query.all()


def search_area_by_type(session, search=None, type_code=None, filter_type_codes=[], limit=50):
    """
    Filter out the areas by the provided params:

    Args:
        session: the db session
        search (str): to be able to filter against the name and the area_code
        filter_type_codes (list): to exclude area codes
        limit (int): restricts the number of objects returns 
    """
    query = (
        session.query(
            VmAreas.id_area,
            VmBibAreasTypes.type_name,
            VmAreas.area_code,
            func.concat("(", VmBibAreasTypes.type_name, ") ", VmAreas.area_name),
        )
        .join(VmBibAreasTypes, VmBibAreasTypes.id_type == VmAreas.id_type)
        
    )
    if type_code is not None:
        filter_type_codes.append(type_code)
    if search is not None:
        search = search.lower()
        query = query.filter(or_(
                    VmAreas.area_name.ilike("%" + search + "%"),
                    VmAreas.area_code.ilike("%" + search + "%")))
    
    query = filter_by_type_codes(query, type_codes=filter_type_codes)

    query = query.limit(limit)
    current_app.logger.debug("<search_area_by_type> query {}".format(query))

    areaList = []
    for r in query.all():
        temp = {"type_name": r.type_name, "label": r[-1], "value": r.id_area}
        areaList.append(temp)
    return areaList


def get_areas_geometries(session, type_code=None, filter_type_codes=[], limit=50):
    """
    Returns a Feature collection of all the areas

    Args:
        session: the db session
        type_code (str): filter out by a type_code
        filter_type_codes (list): ignores the codes provided in this list
        limit (int): restricts the number of objects returns
    
    Returns:
        FeatureCollection: the geometries as geojson
    """
    query = (
        session.query(
            VmAreas.area_name,
            VmAreas.id_area,
            VmAreas.area_geojson,
            VmAreas.area_code,
            VmBibAreasTypes.type_code,
            VmBibAreasTypes.type_name
        )
        .join(VmBibAreasTypes, VmBibAreasTypes.id_type == VmAreas.id_type)
    )
    if type_code is not None:
        filter_type_codes.append(type_code)

    query = filter_by_type_codes(query, type_codes=filter_type_codes)

    query = query.limit(limit)
    return FeatureCollection(
        [
            Feature(
                id=r.id_area,
                geometry=json.loads(r.area_geojson),
                properties={
                    "id_area": r.id_area,
                    "area_name": r.area_name,
                    "area_code": r.area_code,
                    "type_code": r.type_code,
                    "type_name": r.type_name
                },
            )
            for r in query.all()
        ]
    )


def get_areas_observations(session, limit, id_area):
    """
    For a provided area_code and cd_ref, computes the observations in
    this area
    """
    query = (
        session.query(
            VmObservations.id_observation,
            VmObservations.diffusion_level,
            VmTaxref.nom_vern,
            VmTaxref.lb_nom,
            VmTaxref.group2_inpn,
            VmObservations.dateobs,
            VmObservations.observateurs,
            func.st_asgeojson(VmObservations.the_geom_point).label("geometry"),
        )
        .join(VmTaxref, VmTaxref.cd_nom == VmObservations.cd_ref)
        .join(
            VmCorAreaObservation,
            VmObservations.id_observation == VmCorAreaObservation.id_observation,
        )
        .filter(VmCorAreaObservation.id_area == id_area)
    ).limit(limit).all()
    result = []
    for r in query:
        temp = r._asdict()
        temp["geojson_point"] = json.loads(r.geometry or "{}")
        temp["dateobs"] = str(r.dateobs)
        temp["group2_inpn"] = utils.deleteAccent(r.group2_inpn)
        result.append(temp)
    return result


def get_areas_observations_by_cd_ref(session, area_code, cd_ref):
    """
    For a provided area_code and cd_ref, computes grid observations in
    this area
    """
    req = (
        session.query(
            VmObservations.id_observation,
            VmTaxref.nom_vern,
            VmTaxref.lb_nom,
            VmTaxref.group2_inpn,
            VmObservations.dateobs,
            VmObservations.observateurs,
            func.st_asgeojson(VmObservations.the_geom_point).label("geometry"),
        )
        .join(VmTaxref, VmTaxref.cd_nom == VmObservations.cd_ref)
        .join(
            VmCorAreaObservation,
            VmObservations.id_observation == VmCorAreaObservation.id_observation,
        )
        .join(VmAreas, VmAreas.id_area == VmCorAreaObservation.id_area)
        .filter(VmAreas.area_code == area_code, VmObservations.cd_ref == cd_ref)
    ).all()
    result = []
    for r in req:
        temp = r._asdict()
        temp["geojson_point"] = json.loads(r.geometry or "{}")
        temp["dateobs"] = str(r.dateobs)
        temp["group2_inpn"] = utils.deleteAccent(r.group2_inpn)
        result.append(temp)
    return result


def get_areas_grid_observations_by_cd_ref(session, area_code, cd_ref):
    """
    For a provided area_code and cd_ref, computes the observations in
    this area
    """
    query = (
        session.query(
            TGrid.id_maille,
            func.extract("year", VmObservations.dateobs).label("annee"),
            func.st_asgeojson(TGrid.the_geom, 4326).label(
                "geojson_maille"
            ),
        )
        .join(VmAreas, VmAreas.the_geom.st_intersects(VmObservations.the_geom_point))
        .join(TGrid, TGrid.the_geom.st_intersects(VmObservations.the_geom_point))
        .filter(and_(VmObservations.cd_ref == cd_ref, VmAreas.area_code == area_code))
        .order_by(TGrid.id_maille)
    )

    current_app.logger.debug(
        "<get_areas_grid_observations_by_cdnom> QUERY: {}".format(query)
    )
    tabObs = list()
    for o in query.all():
        temp = {
            "id_maille": o.id_maille,
            "nb_observations": 1,
            "annee": o.annee,
            "geojson_maille": json.loads(o.geojson_maille),
        }
        tabObs.append(temp)

    return tabObs


def get_area_taxa(session, id_area):
    """
    Returns the list of taxa observed in the area defined by id_area

    Args:
        session: the db session
        id_area (int): the id of the area
    """
    query = (
        session.query(
            VmTaxons.cd_ref,
            VmTaxons.nom_vern,
            VmTaxons.nom_complet_html,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.url,
            VmMedias.chemin,
            func.count(VmObservations.id_observation).label("nb_obs"),
            func.max(func.extract("year", VmObservations.dateobs)).label("last_obs"),
        )
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .join(
            VmCorAreaObservation,
            VmObservations.id_observation == VmCorAreaObservation.id_observation,
        )
        .outerjoin(
            VmMedias,
            and_(
                VmMedias.cd_ref == VmObservations.cd_ref,
                VmMedias.id_type == current_app.config["ATTR_MAIN_PHOTO"],
            ),
        )
        .filter(VmCorAreaObservation.id_area == id_area)
        .group_by(
            VmTaxons.cd_ref,
            VmTaxons.nom_vern,
            VmTaxons.nom_complet_html,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.url,
            VmMedias.chemin,
        )
        .order_by(-func.count(VmObservations.id_observation))
    )
    current_app.logger.debug("<get_area_taxa> QUERY: {}".format(query))
    current_app.logger.debug("<get_area_taxa> start loop: {}".format(datetime.now()))
    result = []
    nbObsTotal = 0
    for r in query.all():
        temp = r._asdict()
        temp["group2_inpn"] = utils.deleteAccent(r.group2_inpn)
        temp["path"] = utils.findPath(r)
        nbObsTotal = nbObsTotal + r.nb_obs
        result.append(temp)
    current_app.logger.debug("<get_area_taxa> end loop: {}".format(datetime.now()))
    return {"taxons": result, "nbObsTotal": nbObsTotal}


def get_surrounding_areas(session, id_area, filter_type_codes=[]):
    """
    Returns the areas around the given id_area

    Args:
        session: the db session
        id_area (int): the id of the area
    """
    subquery = (
        session.query(VmAreas.id_type, VmAreas.the_geom).filter(VmAreas.id_area == id_area).subquery()
    )

    query = (
        session.query(
            VmAreas.id_area,
            VmAreas.area_name,
            VmAreas.area_code,
            VmBibAreasTypes.type_code,
            VmBibAreasTypes.type_name,
        )
        .join(VmBibAreasTypes, VmAreas.id_type == VmBibAreasTypes.id_type)
        .filter(and_(VmAreas != id_area, VmAreas.the_geom.st_intersects(subquery.c.the_geom.st_buffer(0))))
    )

    query = filter_by_type_codes(query, type_codes=filter_type_codes)
    return query.all()


def stats(session, type_codes):
    """
    Return the total number of area for each type_code provided

    Args:
        session: the db session
        type_codes (list): list of strings of each type code
    """
    sums = []
    for type_code in type_codes:
        # Use a case to be able to select a sum of each type
        sums.append(func.sum(case((VmBibAreasTypes.type_code == type_code, 1), else_=0)).label(type_code))

    query = (
        session.query(*sums)
        .join(VmAreas, VmBibAreasTypes.id_type == VmAreas.id_type))
    return query.first()._asdict()
