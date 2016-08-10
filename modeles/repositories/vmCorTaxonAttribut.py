#! /usr/bin/python
# -*- coding:utf-8 -*-

from sqlalchemy.sql import text



def getAttributesTaxon(connection, cd_ref, attrDesc, attrComment, attrMilieu, attrCorro):
    sql = "SELECT * from atlas.vm_cor_taxon_attribut \
    WHERE id_attribut IN (:thisattrDesc, :thisattrComment, :thisattrMilieu, :thisattrCorro) AND cd_ref = :thiscdref"
    req=connection.execute(text(sql), thiscdref=cd_ref, thisattrDesc=attrDesc, thisattrComment=attrComment, thisattrMilieu=attrMilieu, thisattrCorro=attrCorro)
    
    descTaxon = {'description': None , 'commentaire': None, 'milieu': None, 'corrologie': None}
    for r in req:
        if r.id_attribut == attrDesc:
            descTaxon['description'] = r.valeur_attribut
        elif r.id_attribut == attrComment:
            descTaxon['commentaire'] = r.valeur_attribut
        elif r.id_attribut == attrMilieu:
            descTaxon['milieu'] = r.valeur_attribut
        elif r.id_attribut == attrCorro:
            descTaxon['corrologie'] = r.valeur_attribut
    return descTaxon