# -*- coding:utf-8 -*-

from atlas.modeles.entities.vmTaxons import VmCorTaxonAttribut
from atlas.env import db


def getAttributesTaxon(cd_ref, attrDesc, attrComment, attrMilieu, attrChoro):
    id_attributs = [attrDesc, attrComment, attrMilieu, attrChoro]
    req = db.session.query(VmCorTaxonAttribut).filter(
        VmCorTaxonAttribut.id_attribut.in_(id_attributs), VmCorTaxonAttribut.cd_ref == cd_ref
    )

    descTaxon = {"description": None, "commentaire": None, "milieu": None, "chorologie": None}
    for r in req:
        if r.id_attribut == attrDesc:
            descTaxon["description"] = r.valeur_attribut
        elif r.id_attribut == attrComment:
            descTaxon["commentaire"] = r.valeur_attribut
        elif r.id_attribut == attrMilieu:
            descTaxon["milieu"] = r.valeur_attribut.replace("&", " | ")
        elif r.id_attribut == attrChoro:
            descTaxon["chorologie"] = r.valeur_attribut
    return descTaxon
