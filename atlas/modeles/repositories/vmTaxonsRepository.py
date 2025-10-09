# -*- coding:utf-8 -*-

from flask import current_app
from sqlalchemy import desc
from sqlalchemy.sql import select, distinct, func
from atlas.modeles.entities.vmStatutBdc import CorTaxonStatutArea, TOrdreListeRouge
from atlas.modeles.entities.tBibTaxrefRang import TBibTaxrefRang
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmAreas import VmCorAreaSynthese
from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmAreas import VmCorAreas, VmBibAreasTypes, VmAreas

from atlas.modeles import utils
from atlas.env import db


def get_nb_taxons(cd_ref=None, group_name=None):
    query = select(
        func.count(distinct(VmObservations.cd_ref)).label("nb_taxons"),
        func.count(distinct(VmObservations.id_observation)).label("nb_obs_total"),
    )
    if cd_ref:
        childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
        query = (
            query.join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
            .join(TBibTaxrefRang, func.trim(VmTaxons.id_rang) == func.trim(TBibTaxrefRang.id_rang))
            .filter(VmTaxons.cd_ref.in_(childs_ids))
        )
    if group_name:
        query = query.join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref).filter(
            VmTaxons.group2_inpn == group_name
        )
    results = db.session.execute(query).all()
    return {"nb_taxons": results[0].nb_taxons, "nb_obs_total": results[0].nb_obs_total}


# With distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getListTaxon(id_area=None, group_name=None, page=0, page_size=current_app.config["ITEMS_PER_PAGE"], filter_taxon=""):
    id_photo = current_app.config["ATTR_MAIN_PHOTO"]
    if id_area:
        obs_in_area = (
            select(
                func.count(distinct(VmObservations.id_observation)).label("nb_obs"),
                func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs"),
                VmObservations.cd_ref,
            )
            .select_from(VmObservations)
            .join(
                VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation
            )
            .group_by(VmObservations.cd_ref)
            .filter(VmCorAreaSynthese.id_area == id_area)
        ).subquery()
    else:
        obs_in_area = (
            select(
                func.count(distinct(VmObservations.id_observation)).label("nb_obs"),
                func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs"),
                VmObservations.cd_ref,
            )
            .select_from(VmObservations)
            .group_by(VmObservations.cd_ref)
        ).subquery()

    id_area_dep = select(VmCorAreas.id_area_parent).select_from(VmCorAreas).join(
        VmAreas, VmAreas.id_area == VmCorAreas.id_area_parent
    ).join(VmBibAreasTypes, VmAreas.id_type == VmBibAreasTypes.id_type).filter(
        (VmBibAreasTypes.type_code == 'DEP') & (VmCorAreas.id_area == id_area)
    ).subquery()
    req = (
        select(
            VmTaxons.cd_ref,
            obs_in_area.c.nb_obs,
            obs_in_area.c.last_obs,
            VmTaxons.nom_complet_html,
            VmTaxons.nom_vern,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.url,
            VmMedias.chemin,
            VmMedias.id_media,
            CorTaxonStatutArea.statut_menace,
            CorTaxonStatutArea.niveau_application_menace,
            CorTaxonStatutArea.protege,
        )
        .select_from(VmTaxons)
        .join(obs_in_area, obs_in_area.c.cd_ref == VmTaxons.cd_ref)
        .outerjoin(
            CorTaxonStatutArea,
            (CorTaxonStatutArea.cd_ref == VmTaxons.cd_ref)
            & (CorTaxonStatutArea.id_area == id_area),
        )
        .outerjoin(VmMedias, (VmMedias.cd_ref == VmTaxons.cd_ref) & (VmMedias.id_type == id_photo))
        .order_by(obs_in_area.c.nb_obs.desc())
        .limit(int(page_size))
        .offset(int(page) * int(page_size))
    )
    if filter_taxon:
        req = req.where(VmTaxons.nom_vern.ilike(f"%{filter_taxon}%"))
    if group_name:
        req = req.filter(VmTaxons.group2_inpn == group_name)
    results = db.session.execute(req).all()
    taxonAreasList = list()
    for r in results:
        temp = {
            "nom_complet_html": r.nom_complet_html,
            "nb_obs": r.nb_obs,
            "nom_vern": r.nom_vern,
            "cd_ref": r.cd_ref,
            "last_obs": r.last_obs,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "patrimonial": r.patrimonial,
            "protection_stricte": r.protege,
            "path": utils.findPath(r),
            "id_media": r.id_media,
            "statut_menace": r.statut_menace,
            "niveau_application_menace": r.niveau_application_menace,
        }
        taxonAreasList.append(temp)
    return {"taxons": taxonAreasList}


def getTaxonsChildsList(cd_ref, page=0, page_size=current_app.config["ITEMS_PER_PAGE"], filter_taxon=""):
    id_photo = current_app.config["ATTR_MAIN_PHOTO"]
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    req = (
        select(
            VmTaxons.nom_complet_html,
            VmTaxons.nb_obs,
            VmTaxons.nom_vern,
            VmTaxons.cd_ref,
            VmTaxons.yearmax,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.chemin,
            VmMedias.url,
            VmMedias.id_media,
        )
        .distinct()
        .join(TBibTaxrefRang, func.trim(VmTaxons.id_rang) == func.trim(TBibTaxrefRang.id_rang))
        .outerjoin(VmMedias, (VmMedias.cd_ref == VmTaxons.cd_ref) & (VmMedias.id_type == id_photo))
        .filter(VmTaxons.cd_ref.in_(childs_ids))
        .order_by(VmTaxons.nb_obs.desc())
        .limit(int(page_size))
        .offset(int(page) * int(page_size))
    )
    if filter_taxon:
        req = req.where(VmTaxons.nom_vern.ilike(f"%{filter_taxon}%"))
    results = db.session.execute(req).all()
    taxonRankList = list()
    for r in results:
        temp = {
            "nom_complet_html": r.nom_complet_html,
            "nb_obs": r.nb_obs,
            "nom_vern": r.nom_vern,
            "cd_ref": r.cd_ref,
            "last_obs": r.yearmax,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "patrimonial": r.patrimonial,
            "protection_stricte": r.protection_stricte,
            "path": utils.findPath(r),
            "id_media": r.id_media,
        }
        taxonRankList.append(temp)
    return {"taxons": taxonRankList}


def getINPNgroupPhotos():
    """
    Get list of INPN groups with at least one photo
    """

    req = (
        select(func.count(distinct(VmMedias.id_media)).label("nb_photos"), VmTaxons.group2_inpn)
        .select_from(VmTaxons)
        .join(VmMedias, VmMedias.cd_ref == VmTaxons.cd_ref)
        .group_by(VmTaxons.group2_inpn)
        .order_by(func.count(distinct(VmMedias.id_media)).desc())
    )
    results = db.session.execute(req).all()
    groupList = list()
    for r in results:
        temp = {"group": utils.deleteAccent(r.group2_inpn), "groupAccent": r.group2_inpn}
        groupList.append(temp)
    return groupList


# get all groupINPN
def getAllINPNgroup():
    req = (
        select(func.sum(VmTaxons.nb_obs).label("som_obs"), VmTaxons.group2_inpn)
        .group_by(VmTaxons.group2_inpn)
        .order_by(func.sum(VmTaxons.nb_obs).desc())
    )
    results = db.session.execute(req).all()
    groupList = list()
    for r in results:
        temp = {"group": utils.deleteAccent(r.group2_inpn), "groupAccent": r.group2_inpn}
        groupList.append(temp)
    return groupList
