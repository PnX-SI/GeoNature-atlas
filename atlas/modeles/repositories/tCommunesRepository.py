# -*- coding:utf-8 -*-
import ast

from sqlalchemy.sql import text


def getCommunesObservationsChilds(connection, cd_ref):
    sql = """
    SELECT DISTINCT(com.insee) AS insee, com.commune_maj
    FROM layers.l_communes com
    JOIN atlas.vm_observations obs ON obs.insee = com.insee
    WHERE obs.cd_ref IN (
            SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
        ) OR obs.cd_ref = :thiscdref
    GROUP BY com.commune_maj, com.insee
    """.encode('UTF-8')

    return connection.execute(text(sql), thiscdref=cd_ref)
