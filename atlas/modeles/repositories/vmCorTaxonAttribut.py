# -*- coding:utf-8 -*-

from sqlalchemy.sql import text
import markdown


def getAttributesTaxon(connection, cd_ref, displayed_attr):
    sql = """
        SELECT *
        FROM atlas.vm_cor_taxon_attribut
        WHERE code = ANY(:displayedAttr)
        AND cd_ref = :cdRef
    """
    results = connection.execute(text(sql), cdRef=cd_ref, displayedAttr=displayed_attr)

    desc_taxon = []
    for row in results:
        desc_taxon.append(
            {"code": row.code, "title": row.title, "value": markdown.markdown(row.value)}
        )
    return desc_taxon
