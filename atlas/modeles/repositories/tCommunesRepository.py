# -*- coding:utf-8 -*-
import ast

from sqlalchemy.sql import text


def getGeoEntryObservationsChilds(connection, cd_ref):
    sql = """
    SELECT DISTINCT(e.geo_entry_id) AS geo_entry_id, e.geo_entry_name
    FROM layers.vm_geo_entry e
    JOIN atlas.vm_observations obs ON obs.geo_entry_id = e.geo_entry_id
    WHERE obs.cd_ref IN (
            SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
        ) OR obs.cd_ref = :thiscdref
    GROUP BY e.geo_entry_name, e.geo_entry_id
    """.encode('UTF-8')

    return connection.execute(text(sql), thiscdref=cd_ref)
