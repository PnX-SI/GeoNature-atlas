# -*- coding:utf-8 -*-
from flask import current_app
from sqlalchemy.sql import func, select, literal, or_

from atlas.modeles import utils
from atlas.modeles.entities.tBibTaxrefRang import TBibTaxrefRang
from atlas.modeles.entities.vmTaxref import VmTaxref
from atlas.modeles.entities.vmTaxons import VmTaxons


def searchEspece(session, cd_ref):
    """
    recherche l espece corespondant au cd_nom et tout ces fils
    """
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    limit_obs = (
        select(
            literal(cd_ref).label("cd_ref"),
            func.min(VmTaxons.yearmin).label("yearmin"),
            func.max(VmTaxons.yearmax).label("yearmax"),
            func.sum(VmTaxons.nb_obs).label("nb_obs"),
        )
        .filter(or_(VmTaxons.cd_ref.in_(childs_ids), VmTaxons.cd_ref == cd_ref))
        .subquery()
    )
    req = (
        select(
            VmTaxref,
            limit_obs.c.cd_ref,
            limit_obs.c.yearmin,
            limit_obs.c.yearmax,
            func.coalesce(limit_obs.c.nb_obs, 0).label("nb_obs"),
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
        )
        .join(limit_obs, limit_obs.c.cd_ref == VmTaxref.cd_nom)
        .outerjoin(VmTaxons, VmTaxons.cd_ref == VmTaxref.cd_ref)
        .filter(VmTaxref.cd_nom == cd_ref)
    )
    results = session.execute(req).mappings().all()
    taxonSearch = dict()
    for r in results:
        obj = r["VmTaxref"]
        nom_vern = None
        if obj.nom_vern:
            nom_vern = (
                obj.nom_vern.split(",")[0]
                if current_app.config["SPLIT_NOM_VERN"]
                else obj.nom_vern
            )
        taxonSearch = {
            "cd_ref": r.cd_ref,
            "lb_nom": obj.lb_nom,
            "nom_vern": nom_vern,
            "lb_auteur": obj.lb_auteur,
            "nom_complet_html": obj.nom_complet_html,
            "group2_inpn": utils.deleteAccent(obj.group2_inpn),
            "groupAccent": obj.group2_inpn,
            "yearmin": r.yearmin,
            "yearmax": r.yearmax,
            "nb_obs": r.nb_obs,
            "patrimonial": r.patrimonial,
            "protection": r.protection_stricte,
        }

    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    req = (
        select(
            VmTaxons.lb_nom,
            VmTaxons.nom_vern,
            VmTaxons.cd_ref,
            TBibTaxrefRang.tri_rang,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmTaxons.nb_obs,
        )
        .join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxons.id_rang)
        .filter(VmTaxons.cd_ref.in_(childs_ids))
        .order_by(VmTaxons.lb_nom.asc(), VmTaxons.nb_obs.desc())
    )
    results = session.execute(req).all()
    listTaxonsChild = list()
    for r in results:
        temp = {
            "lb_nom": r.lb_nom,
            "nom_vern": r.nom_vern,
            "cd_ref": r.cd_ref,
            "tri_rang": r.tri_rang,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "patrimonial": r.patrimonial,
            "nb_obs": r.nb_obs,
            "protection": r.protection_stricte,
        }
        listTaxonsChild.append(temp)

    return {"taxonSearch": taxonSearch, "listTaxonsChild": listTaxonsChild}


def getSynonymy(session, cd_ref):
    req = (
        select(VmTaxref.nom_complet_html, VmTaxref.lb_nom)
        .filter(VmTaxref.cd_ref == cd_ref)
        .order_by(VmTaxref.lb_nom.asc())
    )
    results = session.execute(req).all()
    tabSyn = list()
    for r in results:
        temp = {"lb_nom": r.lb_nom, "nom_complet_html": r.nom_complet_html}
        tabSyn.append(temp)
    return tabSyn


def getTaxon(session, cd_nom):
    return (
        session.query(
            VmTaxref.lb_nom,
            VmTaxref.id_rang,
            VmTaxref.cd_ref,
            VmTaxref.cd_taxsup,
            TBibTaxrefRang.nom_rang,
            TBibTaxrefRang.tri_rang,
        )
        .join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang)
        .filter(VmTaxref.cd_nom == cd_nom)
        .one_or_none()
    )


def getCd_sup(session, cd_ref):
    req = session.query(VmTaxref.cd_taxsup).filter(VmTaxref.cd_nom == cd_ref).first()
    return req.cd_taxsup


def getInfoFromCd_ref(session, cd_ref):
    req = (
        session.query(VmTaxref.lb_nom, TBibTaxrefRang.nom_rang)
        .join(TBibTaxrefRang, TBibTaxrefRang.id_rang == VmTaxref.id_rang)
        .filter(VmTaxref.cd_ref == cd_ref)
    )

    return {"lb_nom": req[0].lb_nom, "nom_rang": req[0].nom_rang}


def getAllTaxonomy(session, cd_ref):
    taxonSup = getCd_sup(session, cd_ref)  # cd_taxsup
    taxon = getTaxon(session, taxonSup)
    tabTaxon = list()
    while taxon and taxon.tri_rang >= current_app.config["LIMIT_RANG_TAXONOMIQUE_HIERARCHIE"]:
        temp = {
            "rang": taxon.id_rang,
            "lb_nom": taxon.lb_nom,
            "cd_ref": taxon.cd_ref,
            "nom_rang": taxon.nom_rang,
            "tri_rang": taxon.tri_rang,
        }
        tabTaxon.insert(0, temp)
        taxon = getTaxon(session, taxon.cd_taxsup)  # on avance
    return tabTaxon


def get_cd_ref(session, cd_nom):
    req = select(VmTaxref.cd_ref).filter(VmTaxref.cd_nom == cd_nom)
    row = session.execute(req).one()
    return row.cd_ref
