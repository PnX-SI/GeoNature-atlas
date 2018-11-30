
# -*- coding:utf-8 -*-

from sqlalchemy.sql import text


def getMonthlyObservationsChilds(connection, cd_ref):
    sql = """
    SELECT
        SUM(_01) as _01, SUM(_02) as _02, SUM(_03) as _03,
        SUM(_04) as _04, SUM(_05) as _05, SUM(_06) as _06,
        SUM(_07) as _07, SUM(_08) as _08, SUM(_09) as _09,
        SUM(_10) as _10, SUM(_11) as _11, SUM (_12) as _12
    FROM atlas.vm_mois mois
    WHERE mois.cd_ref in (
            select * from atlas.find_all_taxons_childs(:thiscdref)
        )
        OR mois.cd_ref = :thiscdref
    """

    mesMois = connection.execute(text(sql), thiscdref=cd_ref)
    for inter in mesMois:
        return [
            {'mois': "Janvier", 'value': inter._01},
            {'mois': "Fevrier", 'value': inter._02},
            {'mois': "Mars", 'value': inter._03},
            {'mois': "Avril", 'value': inter._04},
            {'mois': "Mai", 'value': inter._05},
            {'mois': "Juin", 'value': inter._06},
            {'mois': "Juillet", 'value': inter._07},
            {'mois': "Aout", 'value': inter._08},
            {'mois': "Septembre", 'value': inter._09},
            {'mois': "Octobre", 'value': inter._10},
            {'mois': "Novembre", 'value': inter._11},
            {'mois': "Decembre", 'value': inter._12}
        ]