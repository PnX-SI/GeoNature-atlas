#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
import config
from vmTaxref import VmTaxref
from vmTaxons import VmTaxons
from tBibTaxrefRang import TBibTaxrefRang
from sqlalchemy import distinct, func
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker



#recherche l espece corespondant au cd_nom et tout ces fils
def searchEspece(connection, session, cd_ref):
    taxonSearch = session.query(VmTaxref).filter(VmTaxref.cd_ref == cd_ref).all()
    sql="select tax.lb_nom, \
    tax.nom_vern, \
    tax.cd_ref, \
    br.tri_rang \
    from atlas.vm_taxons tax \
    JOIN atlas.bib_taxref_rangs br on br.nom_rang = tax.nom_rang \
    where tax.cd_ref in ( select * from atlas.find_all_taxons_childs(:thiscdref))".encode('utf-8')
    req = connection.execute(text(sql), thiscdref = cd_ref)
    listTaxonsChild = list()
    for r in req:
        temp = {'lb_nom': r.lb_nom, 'nom_vern':r.nom_vern, 'cd_ref':r.cd_ref, 'tri_rang' : r.tri_rang}
        listTaxonsChild.append(temp)
    return {'taxonSearch':taxonSearch[0], 'listTaxonsChild': listTaxonsChild }

def getSynonymy(session, cd_ref):
    return session.query(VmTaxref.lb_nom).filter(VmTaxref.cd_ref==cd_ref).all()


def getCd_ref(cd_nom):
    req = session.query(VmTaxref.cd_ref).filter(VmTaxref.cd_nom == cd_nom).all()
    return req[0].cd_ref

def getTaxon(session, cd_nom):
    req = session.query(VmTaxref.lb_nom, VmTaxref.id_rang, VmTaxref.cd_ref, VmTaxref.cd_taxsup, TBibTaxrefRang.nom_rang, TBibTaxrefRang.tri_rang)\
    .join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang).filter(VmTaxref.cd_nom == cd_nom)
    return req[0]

def getCd_sup(session, cd_ref):
    req = session.query(VmTaxref.cd_taxsup).filter(VmTaxref.cd_nom == cd_ref).first()
    return req.cd_taxsup

def getInfoFromCd_ref(session, cd_ref):
    req = session.query(VmTaxref.lb_nom, TBibTaxrefRang.nom_rang).join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang).filter(VmTaxref.cd_ref == cd_ref)
    return {'lb_nom': req[0].lb_nom, 'nom_rang' : req[0].nom_rang }


def getAllTaxonomy(session, cd_ref):
    taxonSup = getCd_sup(session, cd_ref) #cd_taxsup
    taxon = getTaxon(session, taxonSup)
    tabTaxon = list()
    while taxon.tri_rang >= config.LIMIT_RANG_TAXONOMIQUE_HIERARCHIE : 
        temp = {'rang' : taxon.id_rang, 'lb_nom' : taxon.lb_nom, 'cd_ref': taxon.cd_ref, 'nom_rang' : taxon.nom_rang, 'tri_rang': taxon.tri_rang }
        tabTaxon.insert(0, temp)
        taxon = getTaxon(session, taxon.cd_taxsup) #on avance
    return tabTaxon