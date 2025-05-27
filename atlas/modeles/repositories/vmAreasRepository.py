# -*- coding:utf-8 -*-

import ast

from sqlalchemy import distinct
from sqlalchemy.sql import text
from sqlalchemy.sql.expression import func

from flask import current_app
from werkzeug.exceptions import NotFound
from atlas.modeles.entities.vmAreas import VmAreas, VmBibAreasTypes


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


def getAreaFromIdArea(connection, id_area):
    sql = """
        SELECT area.area_name,
           area.id_area,
           area.area_geojson,
           bib.type_name
        FROM atlas.vm_l_areas area
        JOIN atlas.vm_bib_areas_types bib ON bib.id_type = area.id_type
        WHERE area.id_area = :thisIdArea
    """
    area = connection.execute(text(sql), {"thisIdArea":id_area}).fetchone()
    if not area:
        raise NotFound()
    area_dict = {
        "areaName": area.area_name,
        "areaCode": str(area.id_area),
        "areaGeoJson": ast.literal_eval(area.area_geojson),
        "typeName": area.type_name,
        "areasParent": [],
    }

    sql_area_parent = """
    SELECT l.area_name, l.id_area, bib.type_name
    FROM atlas.vm_l_areas l
    JOIN (
        SELECT id_area_group  
        FROM atlas.vm_cor_areas cor
        WHERE cor.id_area = :thisIdArea
    ) parent ON parent.id_area_group = l.id_area
    JOIN atlas.vm_bib_areas_types bib ON bib.id_type = l.id_type
    """
    areas_parent = connection.execute(text(sql_area_parent), {"thisIdArea":id_area}).fetchall()
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


def getAreasObservationsChilds(connection, cd_ref):
    sql = "SELECT * FROM atlas.find_all_taxons_childs(:thiscdref) AS taxon_childs(cd_nom)"
    results = connection.execute(text(sql), {"thiscdref":cd_ref})
    taxons = [cd_ref]
    for r in results:
        taxons.append(r.cd_nom)

    sql = """
        SELECT
            DISTINCT cas.id_area,
            vla.area_name,
            bat.type_code,
            bat.type_name
        FROM atlas.vm_cor_area_synthese AS cas
                JOIN atlas.vm_observations obs ON cas.id_synthese = obs.id_observation
                JOIN atlas.vm_l_areas vla ON cas.id_area = vla.id_area
                JOIN atlas.vm_bib_areas_types AS bat ON cas.type_code = bat.type_code
        WHERE cas.type_code = ANY(:list_id_type) AND obs.cd_ref = ANY(:taxonsList)
        ORDER BY vla.area_name ASC;
    """

    results = connection.execute(
        text(sql), 
        {"taxonsList":taxons, "list_id_type":current_app.config["TYPE_TERRITOIRE_SHEET"]}
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


def get_species_by_taxonomic_group(connection, id_area):
    """
    Get number of species by taxonimy group:
    """
    sql = """
    SELECT nb_species,
        group2_inpn,
        nb_patrominal,
        nb_species_in_teritory
    FROM atlas.vm_area_stats_by_taxonomy_group
    WHERE id_area = :id_area;
        """

    result = connection.execute(text(sql), {"id_area":id_area})
    info_chart = dict()
    for r in result:
        info_chart[r.group2_inpn] = {
            "nb_species": r.nb_species,
            "nb_patrimonial": r.nb_patrominal,
            "nb_species_in_teritory": r.nb_species_in_teritory,
        }
    return info_chart


def get_nb_observations_taxonomic_group(connection, id_area):
    """
    Get number of species by taxonimy group:
    """
    sql = """
    SELECT nb_obs,
        group2_inpn
    FROM atlas.vm_area_stats_by_taxonomy_group
    WHERE id_area = :id_area;
        """

    result = connection.execute(text(sql), {"id_area":id_area})
    info_chart = dict()
    for r in result:
        info_chart[r.group2_inpn] = r.nb_obs
    return info_chart


def getStatsByArea(connection, id_area):
    sql = """
    SELECT *
    FROM atlas.vm_area_stats
    WHERE id_area = :id_area;
    """
    result = connection.execute(text(sql), {"id_area":id_area}).fetchone()
    if not result:
        raise NotFound()
    return result._asdict()
