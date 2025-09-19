# -*- coding:utf-8 -*-

from atlas.modeles import utils
from sqlalchemy.sql import select, func, and_, or_
from atlas.modeles.entities.vmTaxons import VmTaxonsMostView
from atlas.env import db


def mostViewTaxon():
    req = (
        select(VmTaxonsMostView)
        .filter(
            or_(
                and_(
                    VmTaxonsMostView.day_start >= func.date_part("day", func.now()),
                    VmTaxonsMostView.month_start == func.date_part("month", func.now()),
                ),
                and_(
                    VmTaxonsMostView.day_end < func.date_part("day", func.now()),
                    VmTaxonsMostView.month_end == func.date_part("month", func.now()),
                ),
            )
        )
        .order_by(func.random())
        .limit(12)
    )
    results = db.session.execute(req).mappings().all()
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
