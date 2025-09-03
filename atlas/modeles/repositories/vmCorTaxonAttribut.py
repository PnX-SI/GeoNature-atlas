# -*- coding:utf-8 -*-

import markdown

from atlas.modeles.entities.vmTaxons import VmCorTaxonAttribut
from atlas.env import db


def getAttributesTaxon(cd_ref, displayed_attr):
    results = db.session.query(VmCorTaxonAttribut).filter(
        VmCorTaxonAttribut.code.in_(displayed_attr), VmCorTaxonAttribut.cd_ref == cd_ref
    ).all()

    desc_taxon = []
    for row in results:
        desc_taxon.append(
            {"code": row.code, "title": row.title, "value": markdown.markdown(row.value)}
        )
    # must do it twice because results in a cursor, when you loop over it, items disapear !
    ordered_attr = []
    for att_code in displayed_attr:
        for attr in desc_taxon:
            if attr["code"] == att_code:
                ordered_attr.append(attr)
    return ordered_attr
