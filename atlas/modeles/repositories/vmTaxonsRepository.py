# -*- coding:utf-8 -*-

from flask import current_app
from sqlalchemy import Interval
from sqlalchemy.sql import select, distinct, func, cast, literal, or_
from sqlalchemy.orm import joinedload
from werkzeug.datastructures import MultiDict

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
def getListTaxon(id_area=None, group_name=None, cd_ref=None, params: MultiDict = {}):
    """_summary_

    Parameters
    ----------
    id_area : int, optional
        use for territory sheet
    group_name : str, optional
        use for group INPN sheet
    cd_ref : int, optional
        _use for taxonomy sheet -> find all child taxon of cd_ref to build the list
    params :
        page : int, optional
        page_size : _type_, optional
        filter_taxon : str, optional
            filter list whith lb_nom or nom_vern (use for dynamic search in page)
        protected: boolean
        threatened: boolean
        group2_inpn: str

    Returns
    -------
    _type_
        _description_
    """
    page = int(params.get("page", 0))
    page_size = int(params.get("page_size", current_app.config["ITEMS_PER_PAGE"]))
    filter_taxon = params.get("filter_taxons", "")
    group2_inpn = params.getlist("group2_inpn")
    threatened = params.get("threatened", None)
    protected = params.get("protected", None)
    patrimonial = params.get("patrimonial", None)
    q_stats_taxons = (
        select(
            func.count(distinct(VmObservations.id_observation)).label("nb_obs"),
            func.count(distinct(VmObservations.observateurs)).label("nb_observers"),
            func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs"),
            VmObservations.cd_ref,
        )
        .select_from(VmObservations)
        .group_by(VmObservations.cd_ref)
    )

    if id_area:
        q_stats_taxons = q_stats_taxons.join(
            VmCorAreaSynthese,
            (VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
            & (VmCorAreaSynthese.id_area == id_area)
            & (VmCorAreaSynthese.is_valid_for_display.is_(True)),
        )
    q_stats_taxons = q_stats_taxons.subquery()

    _columns = [
        VmTaxons,
        q_stats_taxons.c.nb_obs,
        q_stats_taxons.c.last_obs,
        q_stats_taxons.c.nb_observers,
    ]
    # si id_area on prend les statuts dans CorTaxonStatutArea sinon directement dans VMTaxons
    if id_area:
        _columns.extend(
            [
                CorTaxonStatutArea.statut_menace.label("menace"),
                CorTaxonStatutArea.niveau_application_menace.label("niveau_application_menace"),
                CorTaxonStatutArea.protege.label("protege"),
            ]
        )
    req = (
        select(*_columns)
        .select_from(VmTaxons)
        .join(q_stats_taxons, q_stats_taxons.c.cd_ref == VmTaxons.cd_ref)
        .order_by(q_stats_taxons.c.nb_obs.desc())
    )
    # if -1 we don't paginate
    if page != -1:
        req = req.limit(page_size).offset(page * page_size)
    if group2_inpn:
        req = req.where(VmTaxons.group2_inpn.in_(group2_inpn))
    req = req.options(joinedload(VmTaxons.main_media))
    conditions = list()
    if id_area:
        id_area_dep = (
            select(VmCorAreas.id_area_parent)
            .select_from(VmCorAreas)
            .join(VmAreas, VmAreas.id_area == VmCorAreas.id_area_parent)
            .join(VmBibAreasTypes, VmAreas.id_type == VmBibAreasTypes.id_type)
            .where((VmBibAreasTypes.type_code == "DEP") & (VmCorAreas.id_area == id_area))
            .scalar_subquery()
        )
        req = req.outerjoin(
            CorTaxonStatutArea,
            (CorTaxonStatutArea.cd_ref == VmTaxons.cd_ref)
            & (CorTaxonStatutArea.id_area.in_(id_area_dep)),
        )
        # si protegé et menacé sur une fiche territoire on va cherché dans CorTaxonStatutArea
        # sinon direcetement dans VmTaxons
        if protected:
            conditions.append(CorTaxonStatutArea.protege == True)
        if threatened:
            conditions.append(CorTaxonStatutArea.statut_menace != None)
    else:
        if protected:
            conditions.append(VmTaxons.protection_stricte == True)
        if threatened:
            conditions.append(VmTaxons.menace == True)

    if patrimonial:
        conditions.append(VmTaxons.patrimonial == "oui")

    if conditions:
        req = req.where(or_(*conditions))

    if group_name:
        req = req.filter(VmTaxons.group2_inpn == group_name)
    if cd_ref:
        childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
        req = req.where(VmTaxons.cd_ref.in_(childs_ids))

    if filter_taxon:
        req = req.where(
            VmTaxons.nom_vern.ilike(f"%{filter_taxon}%")
            | VmTaxons.lb_nom.ilike(f"%{filter_taxon}%")
        )

    taxons = []
    for row in db.session.execute(req).mappings().all():
        taxon_dict = row["VmTaxons"].as_dict(with_main_media=True)
        if id_area:
            taxon_dict["yearmax"] = row.last_obs
            taxon_dict["menace"] = row.menace
            taxon_dict["nb_obs"] = row.nb_obs
            taxon_dict["last_obs"] = row.last_obs
            taxon_dict["nb_observers"] = row.nb_observers
            taxon_dict["protection_stricte"] = row.protege
            taxon_dict["niveau_application_menace"] = row.niveau_application_menace
        taxons.append(taxon_dict)
    return taxons


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


def get_group_inpn(group, id_area=None):
    column = getattr(VmTaxons, group)
    req = select(distinct(column)).select_from(VmTaxons)
    if id_area:
        req = (
            req.join(VmObservations, VmObservations.cd_ref == VmTaxons.cd_ref)
            .join(
                VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation
            )
            .where(VmCorAreaSynthese.id_area == id_area)
        )

    req = req.order_by(column)
    return db.session.execute(req).scalars().all()
