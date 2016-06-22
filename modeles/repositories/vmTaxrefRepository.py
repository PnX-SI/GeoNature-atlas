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
    req = session.query(VmTaxref.lb_nom).filter(VmTaxref.cd_ref==cd_ref)
    return req
    # i = 0
    # for x in req:
    #     i = i+1
    # return {"synonyme" : req, "nbSynonyme": i}
