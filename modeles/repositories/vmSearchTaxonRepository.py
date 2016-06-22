#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmSearchTaxon import VmSearchTaxon
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker


session = manage.loadSession()

#revoie un objet de x tableaux associatifs: 0=nom_search, 1=cd_ref
def listeTaxons():
    return session.query(VmSearchTaxon.nom_search, VmSearchTaxon.cd_ref,).all()