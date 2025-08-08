# -*- coding:utf-8 -*-

import markdown

from sqlalchemy.sql import text


def getAttributesTaxon(connection, cd_ref, displayed_attr):
    sql = """
        SELECT *
        FROM atlas.vm_cor_taxon_attribut
        WHERE code = ANY(:displayedAttr)
            AND cd_ref = :cd_ref
    """
    results = connection.execute(
        text(sql),
        {"cd_ref": cd_ref, "displayedAttr": displayed_attr},
    )
    desc_taxon = []
    for row in results:
        desc_taxon.append({"code": row.code, "title": row.title, "value": markdown.markdown(row.value)})
    # must do it twice because results in a cursor, when you loop over it, items disapear !
    ordered_attr = []
    for att_code in displayed_attr:
        for attr in desc_taxon:
            if attr["code"] == att_code:
                ordered_attr.append(attr)
    return ordered_attr
