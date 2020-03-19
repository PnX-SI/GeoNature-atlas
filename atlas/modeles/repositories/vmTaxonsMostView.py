
# -*- coding:utf-8 -*-

from atlas.modeles import utils
from sqlalchemy.sql import text


def mostViewTaxon(connection):
    sql = "SELECT * FROM atlas.vm_taxons_plus_observes"
    req = connection.execute(text(sql))
    tabTax = list()
    for r in req:
        if r.nom_vern != None:
            nom_verna = r.nom_vern.split(',')
            taxonName = nom_verna[0]+' | ' + r.lb_nom
        else:
            taxonName = r.lb_nom
        temp = {
            'cd_ref': r.cd_ref,
            'taxonName': taxonName,
            'path': utils.findPath(r),
            'group2_inpn': utils.deleteAccent(r.group2_inpn),
            'id_media': r.id_media
        }
        tabTax.append(temp)
    return tabTax
