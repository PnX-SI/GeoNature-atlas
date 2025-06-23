# -*- coding:utf-8 -*-
from sqlalchemy import desc, func, select

from atlas.modeles.entities.vmSearchTaxon import VmSearchTaxon
from atlas.env import db

def listeTaxonsSearch(search, limit=50):
    """
    Recherche dans la VmSearchTaxon en ilike
    Utilisé pour l'autocomplétion de la recherche de taxon

    :query SQLA_Session session
    :query str search : chaine de charactere pour la recherche
    :query int limit: limite des résultats

    **Returns:**

        list: retourne un tableau {'label':'str': 'value': 'int'}
        label = search_name
        value = cd_ref
    """

    idx_trgm_col = func.similarity(VmSearchTaxon.search_name, search).label("idx_trgm")
    search = search.replace(" ", "%")
    subreq = (
        select(VmSearchTaxon.cd_ref, VmSearchTaxon.search_name, idx_trgm_col)
        .filter(VmSearchTaxon.search_name.ilike("%" + search + "%"))
        .order_by(desc(idx_trgm_col), VmSearchTaxon.cd_ref == VmSearchTaxon.cd_nom)
        .limit(limit)
        .subquery()
    )
    req = db.session.query(subreq.c.search_name, subreq.c.cd_ref, subreq.c.idx_trgm).distinct()
    data = req.all()

    return [{"label": d[0], "value": d[1]} for d in data]
