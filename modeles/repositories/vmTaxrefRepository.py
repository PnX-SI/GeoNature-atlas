#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
import config
from vmTaxref import VmTaxref
from tBibTaxrefRang import TBibTaxrefRang
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker


session = manage.loadSession()


def getSynonymy(cd_ref):
    return session.query(VmTaxref.lb_nom).filter(VmTaxref.cd_ref==cd_ref).all()


def getCd_ref(cd_nom):
    req = session.query(VmTaxref.cd_ref).filter(VmTaxref.cd_nom == cd_nom).all()
    return req[0].cd_ref

def getTaxon(cd_nom):
    req = session.query(VmTaxref.lb_nom, VmTaxref.id_rang, VmTaxref.cd_ref, VmTaxref.cd_taxsup, TBibTaxrefRang.nom_rang, TBibTaxrefRang.tri_rang)\
    .join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang).filter(VmTaxref.cd_nom == cd_nom)
    return req[0]

def getCd_sup(cd_ref):
    req = session.query(VmTaxref.cd_taxsup).filter(VmTaxref.cd_nom == cd_ref).first()
    return req.cd_taxsup

def getInfoFromCd_ref(cd_ref):
    req = session.query(VmTaxref.lb_nom, TBibTaxrefRang.nom_rang).join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang).filter(VmTaxref.cd_ref == cd_ref)
    return {'lb_nom': req[0].lb_nom, 'nom_rang' : req[0].nom_rang }


def getAllTaxonomy(cd_ref):
    taxonSup = getCd_sup(cd_ref) #cd_taxsup
    taxon = getTaxon(taxonSup)
    tabTaxon = list()
    while taxon.tri_rang >= config.LIMIT_RANG_TAXONOMIQUE_HIERARCHIE : 
        temp = {'rang' : taxon.id_rang, 'lb_nom' : taxon.lb_nom, 'cd_ref': taxon.cd_ref, 'nom_rang' : taxon.nom_rang, 'tri_rang': taxon.tri_rang }
        tabTaxon.insert(0, temp)
        taxon = getTaxon(taxon.cd_taxsup) #on avance
    return tabTaxon