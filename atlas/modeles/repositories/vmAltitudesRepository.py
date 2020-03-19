# -*- coding:utf-8 -*-

from sqlalchemy.sql import text


def getAltitudesChilds(connection, cd_ref):
    # construction du select  de la requete a partir des cles de la table
    sql = """
        SELECT label_altitude
        FROM atlas.bib_altitudes
        ORDER BY altitude_min
    """
    qalt = connection.execute(text(sql))
    alt = [k[0] for k in qalt]

    sumSelect = ', '.join(
        "SUM({}) AS {}".format(k, k) for k in alt
    )

    sql = """
        SELECT {sumSelect}
        FROM atlas.vm_altitudes alt
        WHERE
            alt.cd_ref IN (
                SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
            ) OR alt.cd_ref = :thiscdref
    """.format(sumSelect=sumSelect)
    mesAltitudes = connection.execute(text(sql), thiscdref=cd_ref)

    altiList = list()
    for a in mesAltitudes:
        for k in alt:
            temp = {"altitude": k.replace('_', '-')[1:], "value": getattr(a, k)}
            altiList.append(temp)

    return altiList
