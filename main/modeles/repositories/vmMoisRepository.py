
# -*- coding:utf-8 -*-

from sqlalchemy.sql import text
from flask.ext.babel import gettext


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
    """.encode('UTF-8')

    mesMois = connection.execute(text(sql), thiscdref=cd_ref)
    for inter in mesMois:
        return [
            {'mois': gettext('graph.janv'), 'value': inter._01},
            {'mois': gettext('graph.fev'), 'value': inter._02},
            {'mois': gettext('graph.mar'), 'value': inter._03},
            {'mois': gettext('graph.avr'), 'value': inter._04},
            {'mois': gettext('graph.mai'), 'value': inter._05},
            {'mois': gettext('graph.jui'), 'value': inter._06},
            {'mois': gettext('graph.juil'), 'value': inter._07},
            {'mois': gettext('graph.aou'), 'value': inter._08},
            {'mois': gettext('graph.sep'), 'value': inter._09},
            {'mois': gettext('graph.oct'), 'value': inter._10},
            {'mois': gettext('graph.nov'), 'value': inter._11},
            {'mois': gettext('graph.dec'), 'value': inter._12}
        ]