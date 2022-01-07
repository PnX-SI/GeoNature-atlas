# -*- coding:utf-8 -*-

import ast

from flask import current_app
from sqlalchemy import distinct
from sqlalchemy.sql import text
from sqlalchemy.sql.expression import func

from atlas.modeles.entities.vmGeoEntry import VmGeoEntry


def getAllGeoEntry(session):
    req = session.query(distinct(VmGeoEntry.geo_entry_name), VmGeoEntry.geo_entry_id).all()
    geoentryList = list()
    for r in req:
        temp = {"label": r[0], "value": r[1]}
        geoentryList.append(temp)
    return geoentryList


def getGeoEntrySearch(session, search, limit=50):
    req = session.query(
        distinct(VmGeoEntry.geo_entry_name),
        VmGeoEntry.geo_entry_id,
        func.length(VmGeoEntry.geo_entry_name),
    ).filter(VmGeoEntry.geo_entry_name.ilike("%" + search + "%"))


    req = req.order_by(VmGeoEntry.geo_entry_name)

    req = req.limit(limit).all()

    geoentryList = list()
    for r in req:
        temp = {"label": r[0], "value": r[1]}
        geoentryList.append(temp)
    return geoentryList


def getGeoEntryFromId(connection, geo_entry_id):
    sql = """
        SELECT e.geo_entry_name,
           e.geo_entry_id,
           e.geo_entry_geojson
        FROM atlas.vm_geo_entry e
        WHERE e.geo_entry_id = :thisId
    """
    req = connection.execute(text(sql), thisId=geo_entry_id)
    geoentryObj = dict()
    for r in req:
        geoentryObj = {
            "areaName": r.geo_entry_name,
            "areaCode": str(r.geo_entry_id),
            "areaGeoJson": ast.literal_eval(r.geo_entry_geojson),
        }
    return geoentryObj


def getGeoEntryObservationsChilds(connection, cd_ref):
    sql = """
        SELECT DISTINCT (e.geo_entry_id) AS geo_entry_id, e.geo_entry_name
        FROM atlas.vm_geo_entry e
        JOIN atlas.vm_observations obs
        ON obs.geo_entry_id = e.geo_entry_id
        WHERE obs.cd_ref IN (
                SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
            )
            OR obs.cd_ref = :thiscdref
        ORDER BY e.geo_entry_name ASC
    """
    req = connection.execute(text(sql), thiscdref=cd_ref)
    listGeoEntry = list()
    for r in req:
        temp = {"geo_entry_id": r.geo_entry_id, "geo_entry_name": r.geo_entry_name}
        listGeoEntry.append(temp)
    return listGeoEntry
