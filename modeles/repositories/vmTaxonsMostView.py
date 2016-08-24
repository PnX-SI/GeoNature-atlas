#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import manage 
from modeles import utils
from sqlalchemy.sql import text
import config
from modeles import utils


def mostViewTaxon(connection):
    sql = "SELECT * FROM atlas.vm_taxons_most_view_temp"
    req = connection.execute(text(sql))
    tabTax = list()
    for r in req:
        if r.nom_vern != None:
            nom_verna = r.nom_vern.split(',')
            taxonName = nom_verna[0]+' | ' + r.lb_nom
        else:
            taxonName = r.lb_nom
        temp ={'cd_ref': r.cd_ref, 'taxonName':taxonName, 'path': utils.findPath(r), 'group2_inpn': utils.deleteAccent(r.group2_inpn)}
        tabTax.append(temp)
    return tabTax