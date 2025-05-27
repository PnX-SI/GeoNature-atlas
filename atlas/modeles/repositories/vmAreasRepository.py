# -*- coding:utf-8 -*-

import ast

from sqlalchemy import distinct, select
from sqlalchemy.sql.expression import func 
from sqlalchemy.dialects.postgresql import array

from flask import current_app
from werkzeug.exceptions import NotFound
from atlas.modeles.entities.vmAreas import (VmAreas, VmBibAreasTypes, 
                                            VmCorAreas, VmCorAreaSynthese, 
                                            VmAreaStatTaxonomyGroup, VmAreaStats)
from atlas.modeles.entities.vmObservations import VmObservations


def getAllAreas(session):
    req = session.query(distinct(VmAreas.area_name), VmAreas.id_area).all()
    areaList = list()
    for r in req:
        temp = {"label": r[0], "value": r[1]}
        areaList.append(temp)
    return areaList


def searchAreas(session, search, limit=50):
    like_search = "%" + search.replace(" ", "%") + "%"

    query = (
        session.query(distinct(VmAreas.area_name), VmAreas.id_area, VmBibAreasTypes.type_name)
        .join(VmBibAreasTypes)
        .filter(func.unaccent(VmAreas.area_name).ilike(func.unaccent(like_search)))
        .filter(VmBibAreasTypes.type_code.in_(current_app.config["TYPE_TERRITOIRE_SHEET"]))
        .order_by(VmAreas.area_name)
        .limit(limit)
    )

    results = query.all()
    return [{"label": r[0], "value": r[1], "type_name": r[2]} for r in results]


def getAreaFromIdArea(session, id_area):
    area = (
        session.query(
            VmAreas.area_name, VmAreas.id_area, 
            VmAreas.area_geojson, 
            VmBibAreasTypes.type_name
        )
        .join(VmBibAreasTypes, VmAreas.id_type == VmBibAreasTypes.id_type)
        .filter(VmAreas.id_area == id_area).one_or_none())
    
    if not area:
        raise NotFound()
    area_dict = {
        "areaName": area.area_name,
        "areaCode": str(area.id_area),
        "areaGeoJson": ast.literal_eval(area.area_geojson),
        "typeName": area.type_name,
        "areasParent": [],
    }

    subquery = (
        session.query(VmCorAreas.id_area_group)
        .filter(VmCorAreas.id_area == id_area)
        .subquery()
        )
    
    areas_parent = (
        session.query(VmAreas.area_name, VmAreas.id_area, VmBibAreasTypes.type_name)
        .join(subquery, subquery.c.id_area_group == VmAreas.id_area)
        .join(VmBibAreasTypes, VmBibAreasTypes.id_type == VmAreas.id_type).all()
    )
    
    areas_parent_serialized = [
        {
            "areaName": area.area_name,
            "areaCode": str(area.id_area),
            "typeName": area.type_name,
        }
        for area in areas_parent
    ]
    area_dict["areasParent"] = areas_parent_serialized
    return area_dict


def getAreasObservationsChilds(session, cd_ref):
    results = (session.execute(
        select(func.atlas.find_all_taxons_childs(cd_ref)))
    ).scalars().all()
    taxons = [cd_ref]
    for r in results:
        taxons.append(r)

    param = {"taxonsList":taxons, "list_id_type":current_app.config["TYPE_TERRITOIRE_SHEET"]}
    results = (
        session.query(distinct(VmCorAreaSynthese.id_area).label("id_area"), 
                      VmAreas.area_name.label("area_name"), 
                      VmBibAreasTypes.type_code.label("type_code"), 
                      VmBibAreasTypes.type_name.label("type_name"))
                      .join(VmObservations, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
                      .join(VmAreas, VmCorAreaSynthese.id_area ==  VmAreas.id_area)
                      .join(VmBibAreasTypes, VmCorAreaSynthese.type_code == VmBibAreasTypes.type_code)
                      .filter(
                          VmCorAreaSynthese.type_code == func.any(array(param["list_id_type"])),
                          VmObservations.cd_ref == func.any(array(param["taxonsList"]))
                      ).order_by(VmAreas.area_name.asc()).all()        
        )

    areas = {}
    nb_territory = 0
    nb_area_type = 0
    for r in results:
        municipality = {
            "id_area": r.id_area,
            "area_name": r.area_name,
            "type_name": r.type_name,
        }
        if r.type_code not in areas:
            areas[r.type_code] = []
            nb_area_type += 1
        areas[r.type_code].append(municipality)
        nb_territory += 1
    areas["length"] = nb_territory
    areas["nb_area_type"] = nb_area_type
    return areas


def get_species_by_taxonomic_group(session, id_area):
    """
    Get number of species by taxonimy group:
    """
    result = (
        session.query(
            VmAreaStatTaxonomyGroup.nb_species.label("nb_species"),
            VmAreaStatTaxonomyGroup.group2_inpn.label("group2_inpn"),
            VmAreaStatTaxonomyGroup.nb_patrominal.label("nb_patrominal"),
            VmAreaStatTaxonomyGroup.nb_species_in_teritory.label("nb_species_in_teritory")
        )
        .filter(VmAreaStatTaxonomyGroup.id_area == id_area)
        .all()
    )
    info_chart = dict()
    for r in result:
        info_chart[r.group2_inpn] = {
            "nb_species": r.nb_species,
            "nb_patrimonial": r.nb_patrominal,
            "nb_species_in_teritory": r.nb_species_in_teritory,
        }
    return info_chart


def get_nb_observations_taxonomic_group(session, id_area):
    """
    Get number of species by taxonimy group:
    """
    result = (
        session.query(
            VmAreaStatTaxonomyGroup.nb_obs.label("nb_obs"),
            VmAreaStatTaxonomyGroup.group2_inpn.label("group2_inpn")
        )
        .filter(VmAreaStatTaxonomyGroup.id_area == id_area)
        .all()
    )
    info_chart = dict()
    for r in result:
        info_chart[r.group2_inpn] = r.nb_obs
    return info_chart


def getStatsByArea(session, id_area):
    result = (
        session.query(VmAreaStats)
            .filter(VmAreaStats.id_area == id_area)
            .one_or_none()
    )
    if not result:
        raise NotFound()
    return result.as_dict()
