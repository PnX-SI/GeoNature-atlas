#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmTaxref import VmTaxref
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker


session = manage.loadSession()


def getSynonymy(cd_ref):
    return session.query(VmTaxref.lb_nom).filter(VmTaxref.cd_ref==cd_ref).all()


def getCd_ref(cd_nom):
    req = session.query(VmTaxref.cd_ref).filter(VmTaxref.cd_nom == cd_nom).all()
    return req[0].cd_ref

def getTaxon(cd_nom):
    req = session.query(VmTaxref.lb_nom, VmTaxref.id_rang, VmTaxref.cd_ref, VmTaxref.cd_taxsup, VmTaxref.id_rang).filter(VmTaxref.cd_nom == cd_nom)
    return req[0]

def getCd_sup(cd_ref):
    req = session.query(VmTaxref.cd_taxsup).filter(VmTaxref.cd_nom == cd_ref).first()
    return req.cd_taxsup

def getNameFromCd_ref(cd_ref):
    req = session.query(VmTaxref.lb_nom).filter(VmTaxref.cd_ref == cd_ref)
    return req [0].lb_nom


def getAllTaxonomy(cd_ref):
    taxonSup = getCd_sup(cd_ref) #cd_taxsup
    taxon = getTaxon(taxonSup)
    tabTaxon = list()
    while 'CL' not in taxon.id_rang.encode('UTF-8'): 
        temp = {'rang' : taxon.id_rang, 'lb_nom' : taxon.lb_nom, 'cd_ref': taxon.cd_ref, 'id_rang' : taxon.id_rang }
        tabTaxon.insert(0, temp)
        taxon = getTaxon(taxon.cd_taxsup) #on avance
    return tabTaxon