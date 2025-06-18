import json
from datetime import datetime

from flask import current_app
from geojson import Feature, FeatureCollection
from sqlalchemy.sql import func, or_, literal, cast
from sqlalchemy import Interval, distinct, select
from sqlalchemy.dialects.postgresql import array

from atlas.modeles import utils
from atlas.modeles.repositories.vmMedias import VmMedias
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmTaxref import VmTaxref
from atlas.modeles.entities.vmAreas import VmCorAreaSynthese, VmAreas, VmBibAreasTypes
from atlas.env import db

currentYear = datetime.now().year


def searchObservationsChilds(cd_ref):
    subquery = select(func.atlas.find_all_taxons_childs(cd_ref))
    query = db.session.query(VmObservations).filter(
        or_(
            VmObservations.cd_ref.in_(subquery),
            VmObservations.cd_ref == cd_ref,
        )
    )
    observations = query.all()

    features = []
    for o in observations:
        feature = Feature(
            id=o.id_observation,
            geometry=json.loads(o.geojson_point or "{}"),
            properties=o.as_dict(),
        )
        features.append(feature)

    return FeatureCollection(features)


def firstObservationChild(cd_ref):
    childs_ids = db.session.query(func.atlas.find_all_taxons_childs(cd_ref))
    req = (
        db.session.query(func.min(VmTaxons.yearmin).label("yearmin"))
        .join(VmTaxref, VmTaxref.cd_ref == VmTaxons.cd_ref)
        .filter(or_(VmTaxons.cd_ref.in_(childs_ids), VmTaxons.cd_ref == cd_ref))
        .all()
    )
    for r in req:
        return r.yearmin


def lastObservations(mylimit, idPhoto):
    req = (
        select(
            VmObservations,
            func.concat(
                func.split_part(VmTaxons.nom_vern, ",", 1) + " | ",
                literal("<i>"),
                VmTaxons.lb_nom,
                literal("</i>"),
            ).label("taxon"),
            VmTaxons.group2_inpn,
            VmMedias.url,
            VmMedias.chemin,
            VmMedias.id_media,
        )
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .outerjoin(
            VmMedias, (VmMedias.cd_ref == VmObservations.cd_ref) & (VmMedias.id_type == idPhoto)
        )
        .where(
            VmObservations.dateobs >= func.current_timestamp() - cast(literal(mylimit), Interval)
        )
        .order_by(VmObservations.dateobs.desc())
    )

    results = db.session.execute(req).mappings().all()

    obsList = []
    for row in results:
        obs = row["VmObservations"]  # Objet ORM VmObservations
        temp = {**obs.__dict__, **row}
        temp.pop("VmObservations")  # supression car partie isolée dans obs
        temp.pop("_sa_instance_state", None)  # supression du champ interne de SQLAlchemy
        temp.pop("the_geom_point", None)
        temp["geojson_point"] = json.loads(obs.geojson_point or "{}")
        temp["dateobs"] = obs.dateobs
        temp["group2_inpn"] = utils.deleteAccent(row["group2_inpn"])
        temp["pathImg"] = utils.findPath(row)
        obsList.append(temp)
    return obsList


def getObservationsByArea(id_area, limit):
    req = (
        select(
            VmObservations,
            func.concat(
                func.split_part(VmTaxons.nom_vern, ",", 1) + " | ",
                literal("<i>"),
                VmTaxons.lb_nom,
                literal("</i>"),
            ).label("taxon"),
            VmObservations.id_observation,
        )
        .join(VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .filter(VmCorAreaSynthese.id_area == id_area)
        .order_by(VmObservations.dateobs.desc())
    )
    if limit:
        req = req.limit(limit)

    results = db.session.execute(req).mappings().all()
    obsList = list()
    for row in results:
        obs = row["VmObservations"]
        temp = {**obs.__dict__, **row}
        temp.pop("VmObservations")  # supression car partie isolée dans obs
        temp.pop("_sa_instance_state", None)  # supression du champ interne de SQLAlchemy
        temp.pop("the_geom_point", None)
        temp["geojson_point"] = json.loads(obs.geojson_point or "{}")
        temp["dateobs"] = obs.dateobs
        temp["id_observation"] = obs.id_observation
        obsList.append(temp)
    return obsList


def getObservationTaxonArea(id_area, cd_ref):
    req = (
        select(VmObservations.geojson_point, VmObservations.dateobs)
        .join(VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .filter(VmCorAreaSynthese.id_area == id_area, VmObservations.cd_ref == cd_ref)
    )
    results = db.session.execute(req).mappings().all()
    obsList = list()
    for row in results:
        temp = {**row}
        temp["geojson_point"] = json.loads(row.geojson_point or "{}")
        temp["dateobs"] = row.dateobs
        obsList.append(temp)
    return obsList


def observersParser(req):
    setObs = set()
    tabObs = list()
    for r in req:
        if r.observateurs != None:
            tabObs = r.observateurs.replace(" & ", ", ").split(", ")
        for o in tabObs:
            o = o.lower()
            setObs.add(o)
    finalList = list()
    for s in setObs:
        tabInter = s.split(" ")
        fullName = str()
        i = 0
        while i < len(tabInter):
            if i == len(tabInter) - 1:
                fullName += tabInter[i].capitalize()
            else:
                fullName += tabInter[i].capitalize() + " "
            i = i + 1
        finalList.append(fullName)
    return sorted(finalList)


def getObservers(cd_ref):
    childs_ids = db.session.execute(select(func.atlas.find_all_taxons_childs(cd_ref))).scalars().all()
    taxons = [cd_ref] + childs_ids  

    req = select(distinct(VmObservations.observateurs).label("observateurs")).filter(
        VmObservations.cd_ref == func.any(array(taxons))
    )
    results = db.session.execute(req).all()
    return observersParser(results)


def getGroupeObservers(groupe):
    subquery = select(VmTaxons.cd_ref).filter(VmTaxons.group2_inpn == groupe)
    req = select(distinct(VmObservations.observateurs).label("observateurs")).filter(
        VmObservations.cd_ref.in_(subquery)
    )
    results = db.session.execute(req).all()
    return observersParser(results)


def getObserversArea(id_area):
    req = (
        select(distinct(VmObservations.observateurs).label("observateurs"))
        .join(VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .filter(VmCorAreaSynthese.id_area == id_area)
    )
    results = db.session.execute(req).all()
    return observersParser(results)


def statIndex():
    result = {"nbTotalObs": None, "nbTotalTaxons": None, "town": None, "photo": None}
    req = select(func.count(VmObservations.id_observation).label("count"))
    results = db.session.execute(req).all()
    for r in results:
        result["nbTotalObs"] = r.count

    type_code = current_app.config["TYPE_TERRITOIRE_SHEET"]
    req = (
        select(func.count(VmAreas.id_area).label("count"))
        .join(VmBibAreasTypes, VmBibAreasTypes.id_type == VmAreas.id_type)
        .filter(VmBibAreasTypes.type_code.in_(type_code))
    )
    results = db.session.execute(req).all()
    for r in results:
        result["town"] = r.count

    req = select(func.count(distinct(VmTaxons.cd_ref)).label("count"))
    results = db.session.execute(req).all()
    for r in results:
        result["nbTotalTaxons"] = r.count

    id_type1 = current_app.config["ATTR_MAIN_PHOTO"]
    id_type2 = current_app.config["ATTR_OTHER_PHOTO"]
    req = (
        select(func.count(distinct(VmMedias.id_media)).label("count"))
        .join(VmTaxons, VmTaxons.cd_ref == VmMedias.cd_ref)
        .filter(VmMedias.id_type.in_([id_type1, id_type2]))
    )
    results = db.session.execute(req).all()
    for r in results:
        result["photo"] = r.count
    return result


def genericStat(tab):
    tabStat = list()
    for pair in tab:
        rang, nomTaxon = list(pair.items())[0]
        # Accès dynamique à la colonne VmTaxons.rang
        colonne_rang = getattr(VmTaxons, rang)
        req = (
            select(
                func.count(distinct(VmObservations.id_observation)).label("nb_obs"),
                func.count(distinct(VmTaxons.cd_ref)).label("nb_taxons"),
            )
            .join(VmObservations, VmObservations.cd_ref == VmTaxons.cd_ref)
            .filter(colonne_rang.in_(nomTaxon))
        )
        results = db.session.execute(req).all()
        for r in results:
            temp = {"nb_obs": r.nb_obs, "nb_taxons": r.nb_taxons}
            tabStat.append(temp)
    return tabStat


def genericStatMedias(tab):
    tabStat = list()
    for i in range(len(tab)):
        rang, nomTaxon = list(tab[i].items())[0]
        colonne_rang = getattr(VmTaxons, rang)
        req = (
            select(
                VmTaxons.nb_obs,
                VmTaxons.cd_ref,
                VmTaxons.lb_nom,
                VmTaxons.nom_vern,
                VmTaxons.group2_inpn,
                VmMedias.url,
                VmMedias.chemin,
                VmMedias.auteur,
                VmMedias.id_media,
            )
            .join(VmMedias, (VmMedias.cd_ref == VmTaxons.cd_ref) & (VmMedias.id_type == 1))
            .filter(colonne_rang.in_(nomTaxon))
            .order_by(func.random())
            .limit(10)
        )
        results = db.session.execute(req).all()
        tabStat.insert(i, list())
        for r in results:
            shorterName = None
            if r.nom_vern != None:
                shorterName = r.nom_vern.split(",")
                shorterName = shorterName[0]
            temp = {
                "cd_ref": r.cd_ref,
                "lb_nom": r.lb_nom,
                "nom_vern": shorterName,
                "path": utils.findPath(r),
                "author": r.auteur,
                "group2_inpn": utils.deleteAccent(r.group2_inpn),
                "nb_obs": r.nb_obs,
                "id_media": r.id_media,
            }
            tabStat[i].append(temp)
    if len(tabStat[0]) == 0:
        return None
    else:
        return tabStat


def getLastDiscoveries():
    id_type = current_app.config["ATTR_MAIN_PHOTO"]
    subreq = (
        select(func.date(func.min(VmObservations.dateobs)).label("date"), VmObservations.cd_ref)
        .group_by(VmObservations.cd_ref)
        .order_by(func.date(func.min(VmObservations.dateobs)).desc())
        .subquery("t")
    )
    req = (
        select(
            subreq.c.date,
            subreq.c.cd_ref,
            VmTaxref.lb_nom,
            VmTaxref.nom_vern,
            VmMedias.id_media,
            VmMedias.chemin,
            VmMedias.url,
            VmTaxref.group2_inpn,
        )
        .join(VmTaxref, VmTaxref.cd_nom == subreq.c.cd_ref)
        .outerjoin(VmMedias, (VmMedias.cd_ref == subreq.c.cd_ref) & (VmMedias.id_type == id_type))
        .filter(VmTaxref.id_rang == "ES")
        .order_by(subreq.c.date.desc())
        .limit(6)
    )
    results = db.session.execute(req).all()
    lastDiscoveriesList = list()
    for r in results:
        temp = {
            "date": r.date,
            "cd_ref": r.cd_ref,
            "nom_vern": r.nom_vern,
            "lb_nom": r.lb_nom,
            "id_media": r.id_media,
            "group2_inpn": utils.deleteAccent(r.group2_inpn),
            "media_path": r.chemin if r.chemin is not None else r.url,
        }
        lastDiscoveriesList.append(temp)
    return lastDiscoveriesList
