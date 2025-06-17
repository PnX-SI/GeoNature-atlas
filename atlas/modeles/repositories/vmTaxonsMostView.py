# -*- coding:utf-8 -*-

from atlas.modeles import utils
from sqlalchemy.sql import select
from atlas.modeles.entities.vmTaxons import VmTaxonsMostView


def mostViewTaxon(session):
    req = select(VmTaxonsMostView)
    results = session.execute(req).mappings().all()
    tabTax = list()
    for r in results:
        obj = r["VmTaxonsMostView"]
        if obj.nom_vern is not None:
            nom_verna = obj.nom_vern.split(",")
            taxonName = nom_verna[0] + " | " + "<i>" + obj.lb_nom + "</i>"
        else:
            taxonName = "<i>" + obj.lb_nom + "</i>"
        temp = {
            "cd_ref": obj.cd_ref,
            "taxonName": taxonName,
            "path": utils.findPath(obj),
            "group2_inpn": utils.deleteAccent(obj.group2_inpn),
            "id_media": obj.id_media,
        }
        tabTax.append(temp)
    return tabTax
