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

    # i = 0
    # for x in req:
    #     i = i+1
    # return {"synonyme" : req,
    #          "nbSynonyme": i,
    #          "ordre"}

def getTaxonomy(cd_ref):
	req= session.query(VmTaxref.ordre, VmTaxref.famille).filter(VmTaxref.cd_ref==cd_ref).limit(1).all()
	return req[0]

