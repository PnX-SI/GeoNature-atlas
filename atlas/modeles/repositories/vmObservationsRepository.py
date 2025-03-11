import json
from datetime import datetime

from flask import current_app
from geojson import Feature, FeatureCollection
from sqlalchemy.sql import text, func, or_

from atlas.modeles import utils
from atlas.env import db
from atlas.utils import GenericTable
from atlas.modeles.repositories import vmMedias
from atlas.modeles.entities.vmObservations import VmObservations

currentYear = datetime.now().year


def searchObservationsChilds(session, cd_ref):
    subquery = session.query(func.atlas.find_all_taxons_childs(cd_ref))
    query = session.query(VmObservations).filter(
        or_(
            VmObservations.cd_ref.in_(subquery),
            VmObservations.cd_ref == cd_ref,
        )
    )
    observations = query.all()
    obsList = list()

    features = []
    for o in observations:
        feature = Feature(
            id=o.id_observation,
            geometry=json.loads(o.geojson_point or "{}"),
            properties=o.as_dict(),
        )
        features.append(feature)

    return FeatureCollection(features)


def firstObservationChild(connection, cd_ref):
    sql = """SELECT min(taxons.yearmin) AS yearmin
    FROM atlas.vm_taxons taxons
    JOIN atlas.vm_taxref taxref ON taxref.cd_ref=taxons.cd_ref
    WHERE taxons.cd_ref IN (
    SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
    )OR taxons.cd_ref = :thiscdref"""
    req = connection.execute(text(sql), thiscdref=cd_ref)
    for r in req:
        return r.yearmin


def lastObservations(connection, mylimit, idPhoto):
    sql = """
    SELECT obs.*,
            CONCAT(
                split_part(tax.nom_vern, ',', 1) || ' | ',
                '<i>',
                tax.lb_nom,
                '</i>'
            ) AS taxon,
        tax.group2_inpn,
        medias.url, medias.chemin, medias.id_media
    FROM atlas.vm_observations obs
    JOIN atlas.vm_taxons tax
        ON tax.cd_ref = obs.cd_ref
    LEFT JOIN atlas.vm_medias medias
        ON medias.cd_ref = obs.cd_ref AND medias.id_type = :thisidphoto
    WHERE  obs.dateobs >= (CURRENT_TIMESTAMP - INTERVAL :thislimit)
    ORDER BY obs.dateobs DESC """

    observations = connection.execute(text(sql), thislimit=mylimit, thisidphoto=idPhoto)

    obsList = list()
    for o in observations:
        temp = dict(o)
        temp.pop("the_geom_point", None)
        temp["geojson_point"] = json.loads(o.geojson_point or "{}")
        temp["dateobs"] = o.dateobs
        temp["type_code"] = o.type_code
        temp["group2_inpn"] = utils.deleteAccent(o.group2_inpn)
        temp["pathImg"] = utils.findPath(o)
        obsList.append(temp)
    return obsList


def lastObservationsArea(connection, obs_limit, id_area):
    sql = """SELECT o.*,
            CONCAT(
                split_part(tax.nom_vern, ',', 1) || ' | ',
                '<i>',
                tax.lb_nom,
                '</i>'
            ) AS taxon,
            o.id_observation
    FROM atlas.vm_observations o
    JOIN atlas.vm_cor_area_synthese AS cas  ON cas.id_synthese = o.id_observation
    JOIN atlas.vm_taxons tax ON  o.cd_ref = tax.cd_ref
    WHERE cas.id_area = :id_area
    ORDER BY o.dateobs DESC
    LIMIT :obsLimit"""
    observations = connection.execute(text(sql), obsLimit=obs_limit, id_area=id_area)
    obsList = list()
    for o in observations:
        temp = dict(o)
        temp.pop("the_geom_point", None)
        temp["geojson_point"] = json.loads(o.geojson_point or "{}")
        temp["dateobs"] = o.dateobs
        temp["id_observation"] = o.id_observation
        obsList.append(temp)
    return obsList


def getObservationTaxonArea(connection, id_area, cd_ref):
    sql = """
        SELECT 
        obs.geojson_point,
        obs.dateobs
        FROM atlas.vm_observations obs
        JOIN atlas.vm_cor_area_synthese AS cas  ON cas.id_synthese = obs.id_observation
        WHERE cas.id_area = :id_area AND obs.cd_ref = :cd_ref
    """

    observations = connection.execute(text(sql), cd_ref=cd_ref, id_area=id_area)
    obsList = list()
    for o in observations:
        temp = dict(o)
        temp["geojson_point"] = json.loads(o.geojson_point or "{}")
        temp["dateobs"] = o.dateobs
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


def getObservers(connection, cd_ref):
    sql = "SELECT * FROM atlas.find_all_taxons_childs(:thiscdref) AS taxon_childs(cd_nom)"
    results = connection.execute(text(sql), thiscdref=cd_ref)
    taxons = [cd_ref]
    for r in results:
        taxons.append(r.cd_nom)

    sql = """
        SELECT DISTINCT observateurs
        FROM atlas.vm_observations
        WHERE cd_ref = ANY(:taxonsList)
    """
    results = connection.execute(text(sql), taxonsList=taxons)
    return observersParser(results)


def getGroupeObservers(connection, groupe):
    sql = """
        SELECT DISTINCT observateurs
        FROM atlas.vm_observations
        WHERE cd_ref IN (
            SELECT cd_ref FROM atlas.vm_taxons WHERE group2_inpn = :thisgroupe
        )
    """
    req = connection.execute(text(sql), thisgroupe=groupe)
    return observersParser(req)


def getObserversArea(connection, id_area):
    sql = """
        SELECT DISTINCT observateurs
        FROM atlas.vm_observations AS obs
        JOIN atlas.vm_cor_area_synthese AS cas ON cas.id_synthese = obs.id_observation
        WHERE cas.id_area = :thisIdArea
    """
    req = connection.execute(text(sql), thisIdArea=id_area)
    return observersParser(req)


def statIndex(connection):
    result = {"nbTotalObs": None, "nbTotalTaxons": None, "town": None, "photo": None}
    sql = """
        SELECT COUNT(*) AS count
        FROM atlas.vm_observations;
    """
    req = connection.execute(text(sql))
    for r in req:
        result["nbTotalObs"] = r.count

    sql = """
        SELECT COUNT(*) AS count
        FROM atlas.vm_l_areas AS vla
        JOIN atlas.vm_bib_areas_types bat ON bat.id_type = vla.id_type
        WHERE bat.type_code = any(:type_code)
    """
    req = connection.execute(text(sql), type_code=current_app.config["TYPE_TERRITOIRE_SHEET"])
    for r in req:
        result["town"] = r.count

    sql = """
        SELECT COUNT(DISTINCT cd_ref) AS count
        FROM atlas.vm_taxons
    """
    connection.execute(text(sql))
    req = connection.execute(text(sql))
    for r in req:
        result["nbTotalTaxons"] = r.count

    sql = """
        SELECT COUNT (DISTINCT id_media) AS count
        FROM atlas.vm_medias m
        JOIN atlas.vm_taxons t ON t.cd_ref = m.cd_ref
        WHERE id_type IN (:id_type1, :id_type2)
    """
    req = connection.execute(
        text(sql),
        id_type1=current_app.config["ATTR_MAIN_PHOTO"],
        id_type2=current_app.config["ATTR_OTHER_PHOTO"],
    )
    for r in req:
        result["photo"] = r.count
    return result


def genericStat(connection, tab):
    tabStat = list()
    for pair in tab:
        rang, nomTaxon = list(pair.items())[0]
        sql = """
            SELECT COUNT (o.id_observation) AS nb_obs,
            COUNT (DISTINCT t.cd_ref) AS nb_taxons
            FROM atlas.vm_taxons t
            JOIN atlas.vm_observations o ON o.cd_ref = t.cd_ref
            WHERE t.{rang} IN :nomTaxon
        """.format(
            rang=rang
        )
        req = connection.execute(text(sql), nomTaxon=tuple(nomTaxon))
        for r in req:
            temp = {"nb_obs": r.nb_obs, "nb_taxons": r.nb_taxons}
            tabStat.append(temp)
    return tabStat


def genericStatMedias(connection, tab):
    tabStat = list()
    for i in range(len(tab)):
        rang, nomTaxon = list(tab[i].items())[0]
        sql = """
            SELECT t.nb_obs, t.cd_ref, t.lb_nom, t.nom_vern, t.group2_inpn,
                m.url, m.chemin, m.auteur, m.id_media
            FROM atlas.vm_taxons t
            JOIN atlas.vm_medias m ON m.cd_ref = t.cd_ref AND m.id_type = 1
            WHERE t.{} IN :nomTaxon
            ORDER BY RANDOM()
            LIMIT 10
        """.format(
            rang
        )
        req = connection.execute(text(sql), nomTaxon=tuple(nomTaxon))
        tabStat.insert(i, list())
        for r in req:
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


def getLastDiscoveries(connection):
    sql = """
        WITH t AS (
            SELECT date(min(vo.dateobs)) date, vo.cd_ref
            FROM atlas.vm_observations vo
            GROUP BY vo.cd_ref
            ORDER BY date desc
        )
        SELECT t.date, t.cd_ref, vt.lb_nom, vt.nom_vern, m.id_media, m.chemin, m.url, vt.group2_inpn
        FROM t
        JOIN atlas.vm_taxref vt ON t.cd_ref = vt.cd_nom
        LEFT JOIN atlas.vm_medias m ON m.cd_ref=t.cd_ref and m.id_type = :thisidtype
        WHERE id_rang = 'ES'
        ORDER BY t.date desc
        LIMIT 6
    """
    req = connection.execute(text(sql), thisidtype=current_app.config["ATTR_MAIN_PHOTO"])
    lastDiscoveriesList = list()
    for r in req:
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
