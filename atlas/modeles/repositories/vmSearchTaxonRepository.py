# -*- coding:utf-8 -*-
from sqlalchemy import desc, func, select

from atlas.modeles.entities.vmSearchTaxon import VmSearchTaxon
from atlas.env import db


def searchTaxons(search, limit=50):
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

    idx_trgm = func.similarity(VmSearchTaxon.search_name, search).label("idx_trgm")
    is_ref_nom = (VmSearchTaxon.cd_ref == VmSearchTaxon.cd_nom).label("is_ref_nom")
    search = search.replace(" ", "%")
    query = (
        select(
            VmSearchTaxon.display_name,
            VmSearchTaxon.cd_ref,
            func.similarity(VmSearchTaxon.search_name, search).label("idx_trgm"),
            (VmSearchTaxon.cd_ref == VmSearchTaxon.cd_nom).label("is_ref_nom")
        )
        .distinct()
        .filter(VmSearchTaxon.search_name.ilike("%" + search + "%"))
        .order_by(desc(idx_trgm), desc(is_ref_nom))
        .limit(limit)
    )
    data = db.session.execute(query).all()

    return [{"label": d[0], "value": d[1]} for d in data]
