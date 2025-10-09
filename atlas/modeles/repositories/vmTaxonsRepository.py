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


def getTaxonsTerritory():
    """ Renvoie la liste de taxon de tout le terrtoire de l'atlas"""
    id_type = current_app.config["ATTR_MAIN_PHOTO"]
    req = (
        select(
            VmObservations.cd_ref,
            func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs"),
            func.count(VmObservations.id_observation).label("nb_obs"),
            VmTaxons.nom_complet_html,
            VmTaxons.nom_vern,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.url,
            VmMedias.chemin,
            VmMedias.id_media,
        )
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .outerjoin(
            VmMedias, (VmMedias.cd_ref == VmObservations.cd_ref) & (VmMedias.id_type == id_type)
        )
        .group_by(
            VmObservations.cd_ref,
            VmTaxons.nom_vern,
            VmTaxons.nom_complet_html,
            VmTaxons.group2_inpn,
            VmTaxons.patrimonial,
            VmTaxons.protection_stricte,
            VmMedias.url,
            VmMedias.chemin,
            VmMedias.id_media,
        )
        .order_by(func.count(VmObservations.id_observation).desc())
        .distinct()
    )
    results = db.session.execute(req).all()
    taxon_list = list()
    nbObsTotal = 0
    for r in results:
        temp = {
            "nom_complet_html": r.nom_complet_html,
            "nb_obs": r.nb_obs,
            "nom_vern": r.nom_vern,
            "cd_ref": r.cd_ref,
            "last_obs": r.last_obs,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "patrimonial": r.patrimonial,
            "protection_stricte": r.protection_stricte,
            "path": utils.findPath(r),
            "id_media": r.id_media,
        }
        taxon_list.append(temp)
        nbObsTotal = nbObsTotal + r.nb_obs
    return {"taxons": taxon_list, "nbObsTotal": nbObsTotal}


# With distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsAreas(id_area):
    id_photo = current_app.config["ATTR_MAIN_PHOTO"]
    
    # sub query to get statistics by cd_ref
    obs_in_area = (
        select(
            VmObservations.cd_ref, 
            func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs"),
            func.count(distinct(VmObservations.id_observation)).label("nb_obs")
        ).select_from(VmObservations)
        .join(VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .filter(VmCorAreaSynthese.id_area == id_area)
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
            (CorTaxonStatutArea.cd_ref == VmTaxons.cd_ref) & 
            (CorTaxonStatutArea.id_area == id_area_dep)   
        )
        .outerjoin(
            VmMedias, (VmMedias.cd_ref == VmTaxons.cd_ref) & (VmMedias.id_type == id_photo)
        )
        .order_by(desc(obs_in_area.c.nb_obs))
    )
    results = db.session.execute(req).all()
    taxonAreasList = list()
    nbObsTotal = 0
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
        nbObsTotal = nbObsTotal + r.nb_obs
    return {"taxons": taxonAreasList, "nbObsTotal": nbObsTotal}


def getTaxonsChildsList(cd_ref):
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
    )
    results = db.session.execute(req).all()
    taxonRankList = list()
    nbObsTotal = 0
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
        nbObsTotal = nbObsTotal + r.nb_obs
    return {"taxons": taxonRankList, "nbObsTotal": nbObsTotal}


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


def getTaxonsGroup(groupe):
    id_photo = current_app.config["ATTR_MAIN_PHOTO"]
    req = (
        select(
            VmTaxons.cd_ref,
            VmTaxons.nom_complet_html,
            VmTaxons.nom_vern,
            VmTaxons.nb_obs,
            VmTaxons.group2_inpn,
            VmTaxons.protection_stricte,
            VmTaxons.patrimonial,
            VmTaxons.yearmax,
            VmMedias.chemin,
            VmMedias.url,
            VmMedias.id_media,
        )
        .outerjoin(VmMedias, (VmMedias.cd_ref == VmTaxons.cd_ref) & (VmMedias.id_type == id_photo))
        .filter(VmTaxons.group2_inpn == groupe)
        .group_by(
            VmTaxons.cd_ref,
            VmTaxons.nom_complet_html,
            VmTaxons.nom_vern,
            VmTaxons.nb_obs,
            VmTaxons.group2_inpn,
            VmTaxons.protection_stricte,
            VmTaxons.patrimonial,
            VmTaxons.yearmax,
            VmMedias.chemin,
            VmMedias.url,
            VmMedias.id_media,
        )
    )
    results = db.session.execute(req).all()
    tabTaxons = list()
    nbObsTotal = 0
    for r in results:
        nbObsTotal = nbObsTotal + r.nb_obs
        temp = {
            "nom_complet_html": r.nom_complet_html,
            "nb_obs": r.nb_obs,
            "nom_vern": r.nom_vern,
            "cd_ref": r.cd_ref,
            "last_obs": r.yearmax,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "patrimonial": r.patrimonial,
            "protection_stricte": r.protection_stricte,
            "id_media": r.id_media,
            "path": utils.findPath(r),
        }
        tabTaxons.append(temp)
    return {"taxons": tabTaxons, "nbObsTotal": nbObsTotal}


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
