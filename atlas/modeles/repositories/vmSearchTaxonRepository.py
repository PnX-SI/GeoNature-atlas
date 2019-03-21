
# -*- coding:utf-8 -*-

from ..entities.vmSearchTaxon import VmSearchTaxon


def listeTaxons(session):
    """
        revoie un tableau d object :
        label = nom latin et nom francais concatene, value = cd_ref
    """
    req = session.query(VmSearchTaxon.nom_search, VmSearchTaxon.cd_ref,).all()
    taxonList = list()
    for r in req:
        temp = {'label': r[0], 'value': r[1]}
        taxonList.append(temp)
    return taxonList

def listeTaxonsSearch(session, search, limit=50):
    req = session.query(VmSearchTaxon.nom_search, VmSearchTaxon.cd_ref,) \
        .filter(VmSearchTaxon.nom_search.ilike('%' + search + '%')).limit(limit).all()
    taxonList = []
    for r in req:
        temp = {'label': r[0], 'value': r[1]}
        taxonList.append(temp)
    return taxonList
