
# -*- coding:utf-8 -*-
import ast
from sqlalchemy.sql import text


def getCommuneFromInsee(connection, insee):
    sql = """
            SELECT l.commune_maj, l.insee,
            st_asgeojson(st_transform(l.the_geom, 4326)) as commune_geojson
            FROM layers.l_communes l
            WHERE l.insee = :thisInsee
        """
    req = connection.execute(text(sql), thisInsee=insee)
    communeObj = dict()
    for r in req:
        communeObj = {
            'communeName': r.commune_maj,
            'insee': r.insee,
            'communeGeoJson': ast.literal_eval(r.commune_geojson)
        }
    return communeObj

    # return req[0].commune_maj # A supprimer


def getCommunesObservationsChilds(connection, cd_ref):
    sql = """
    SELECT distinct(com.insee) as insee, com.commune_maj
    FROM layers.l_communes com
    JOIN atlas.vm_observations obs ON obs.insee = com.insee
    WHERE obs.cd_ref in (
            SELECT * from atlas.find_all_taxons_childs(:thiscdref)
        ) OR obs.cd_ref = :thiscdref
    GROUP BY com.commune_maj, com.insee
    """.encode('UTF-8')

    return connection.execute(text(sql), thiscdref=cd_ref)
