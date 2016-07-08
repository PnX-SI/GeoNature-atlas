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
    req = session.query(VmTaxref.lb_nom, VmTaxref.id_rang, VmTaxref.cd_ref, VmTaxref.cd_taxsup).filter(VmTaxref.cd_nom == cd_nom)
    return req[0]


def getAllTaxonomy(cd_ref):
    taxon = getTaxon(cd_ref)
    tabTaxon = list()
    i = 0
    while 'CL' not in taxon.id_rang.encode('UTF-8'): 
        temp = {'rang' : taxon.id_rang, 'lb_nom' : taxon.lb_nom, 'cd_ref': taxon.cd_ref}
        tabTaxon.insert(0, temp)
        cd_ref_sup = getCd_ref(taxon.cd_taxsup) #renvoie le premier cd_ref du cd_nom
        taxon = getTaxon(cd_ref_sup) #on avance
        i = i+1
    return tabTaxon