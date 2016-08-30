#! /usr/bin/python
# -*- coding:utf-8 -*-

from ..entities.vmSearchTaxon import VmSearchTaxon
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker



#revoie un tableau d object : label = nom latin et nom francais concatene, value = cd_ref
def listeTaxons(session):
    req = session.query(VmSearchTaxon.nom_search, VmSearchTaxon.cd_ref,).all()
    taxonList = list()
    for r in req:
        temp = {'label':r[0], 'value':r[1]}
        taxonList.append(temp)
    return taxonList