# -*- coding:utf-8 -*-

from flask import current_app
from sqlalchemy import Interval
from sqlalchemy.sql import select, distinct, func, cast, literal, and_
from sqlalchemy.orm import joinedload
from werkzeug.datastructures import MultiDict

from atlas.modeles.entities.vmStatutBdc import CorTaxonStatutArea, TOrdreListeRouge
from atlas.modeles.entities.tBibTaxrefRang import TBibTaxrefRang
from atlas.modeles.entities.CorSensitivity import CorSensitivityAreaType
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
        last_obs: boolean : return only last obs (range define in params)
        only_related_sensitivity_level: boolean : optional  - display only species corresponding to the sensitivity level of the id_area (only species with sensitivity=2 for M10 for ex)
        with_local_status: boolean : override global taxon status with local status (eg : protected only in a department)

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
    last_obs = params.get("last_obs", None)
    only_related_sensitivity_level = params.get("only_related_sensitivity_level", None)
    with_local_status = params.get("with_local_status", "true").lower() == "true"
    # CTE 1: Statistics on observations filtered by id_area
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
    if last_obs:
        q_stats_taxons = q_stats_taxons.where(
            VmObservations.dateobs
            >= func.current_timestamp()
            - cast(literal(str(current_app.config["NB_DAY_LAST_OBS"]) + " day"), Interval)
        )
    # filter by id_area
    if id_area:
        q_stats_taxons = q_stats_taxons.join(
            VmCorAreaSynthese,
            (VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
            & (VmCorAreaSynthese.id_area == id_area)
            & (VmCorAreaSynthese.is_valid_for_display.is_(True)),
        )
        if only_related_sensitivity_level:
            q_stats_taxons = q_stats_taxons.join(
                CorSensitivityAreaType,
                (CorSensitivityAreaType.area_type_code == VmCorAreaSynthese.type_code)
                & (VmObservations.cd_sensitivity == CorSensitivityAreaType.sensitivity_code),
            )
    q_stats_taxons_cte = q_stats_taxons.subquery()

    _columns = [
        VmTaxons,
        q_stats_taxons_cte.c.nb_obs,
        q_stats_taxons_cte.c.last_obs,
        q_stats_taxons_cte.c.nb_observers,
    ]

    id_area_parent = None
    q_statut_filtered_cte = None
    # override status with department status indo
    if id_area and with_local_status:
        # get id_area of departement to find status
        # WARNING : la route est appelé por afficher la popup des taxons dans une maille
        # or les id_area des mailles ne sont pas dans atlas.vm_cor_areas
        # les colonnes menace / niveau_application_menace / protege ne sont pas ajouter au retour de la route
        id_area_parent = db.session.execute(
            select(VmCorAreas.id_area_parent)
            .select_from(VmCorAreas)
            .join(VmAreas, VmAreas.id_area == VmCorAreas.id_area_parent)
            .join(VmBibAreasTypes, VmAreas.id_type == VmBibAreasTypes.id_type)
            .where((VmBibAreasTypes.type_code == "DEP") & (VmCorAreas.id_area == id_area))
        ).scalar()

        # CTE 2: Status filtered by id_area only
        if id_area_parent is not None:
            q_statut_filtered = (
                select(
                    CorTaxonStatutArea.cd_ref,
                    CorTaxonStatutArea.id_area,
                    CorTaxonStatutArea.statut_menace,
                    CorTaxonStatutArea.niveau_application_menace,
                    CorTaxonStatutArea.protege,
                )
                .select_from(CorTaxonStatutArea)
                .where(CorTaxonStatutArea.id_area == id_area_parent)
            )
            q_statut_filtered_cte = q_statut_filtered.subquery()

            _columns.extend(
                [
                    q_statut_filtered_cte.c.statut_menace.label("menace"),
                    q_statut_filtered_cte.c.niveau_application_menace.label(
                        "niveau_application_menace"
                    ),
                    q_statut_filtered_cte.c.protege.label("protege"),
                ]
            )

    req = (
        select(*_columns)
        .select_from(VmTaxons)
        .join(q_stats_taxons_cte, q_stats_taxons_cte.c.cd_ref == VmTaxons.cd_ref)
        .order_by(q_stats_taxons_cte.c.nb_obs.desc())
    )
    # if -1 we don't paginate
    if page != -1:
        req = req.limit(page_size).offset(page * page_size)
    if group2_inpn:
        req = req.where(VmTaxons.group2_inpn.in_(group2_inpn))
    req = req.options(joinedload(VmTaxons.main_media))
    conditions = list()

    if id_area and q_statut_filtered_cte is not None:
        req = req.outerjoin(
            q_statut_filtered_cte,
            q_statut_filtered_cte.c.cd_ref == VmTaxons.cd_ref,
        )
        # si protegé et menacé sur une fiche territoire on va cherché dans CorTaxonStatutArea
        # sinon directement dans VmTaxons
        if protected:
            conditions.append(q_statut_filtered_cte.c.protege == True)
        if threatened:
            conditions.append(q_statut_filtered_cte.c.statut_menace.isnot(None))
    else:
        if protected:
            conditions.append(VmTaxons.protection_stricte == True)
        if threatened:
            conditions.append(VmTaxons.menace == True)

    if patrimonial:
        conditions.append(VmTaxons.patrimonial == "oui")

    if conditions:
        req = req.where(and_(*conditions))
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
            taxon_dict["yearmax"] = row.get("last_obs")
            taxon_dict["nb_obs"] = row.get("nb_obs")
            taxon_dict["last_obs"] = row.get("last_obs")
            taxon_dict["nb_observers"] = row.get("nb_observers")
            # si filtre par id_area et qu'on a trouvé l'id_area_parent (département) pour surcharger les statuts
            if id_area_parent:
                taxon_dict["menace"] = row["menace"]
                taxon_dict["protection_stricte"] = row["protege"]
                taxon_dict["niveau_application_menace"] = row["niveau_application_menace"]
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
