# -*- coding:utf-8 -*-
import json

from flask import jsonify, Blueprint, request, current_app

from atlas import utils
from atlas.modeles.repositories import (
    vmSearchTaxonRepository,
    vmObservationsRepository,
    vmObservationsMaillesRepository,
    vmMedias,
    vmAreasRepository,
    vmOrganismsRepository,
)
from atlas.env import cache, db

api = Blueprint("api", __name__)


@api.route("/searchTaxon", methods=["GET"])
def searchTaxonAPI():
    session = db.session
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmSearchTaxonRepository.listeTaxonsSearch(session, search, limit)
    session.close()
    return jsonify(results)


@api.route("/searchArea", methods=["GET"])
def searchAreaAPI():
    session = db.session
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmAreasRepository.searchAreas(session, search, limit)
    session.close()
    return jsonify(results)


@api.route("/observationsMailleTerritory", methods=["GET"])
def getMailleHomeTerritory():
    """
    Retourne les mailles de tout le territoire
    """
    session = db.session
    connection = db.engine.connect()

    current_app.logger.debug("start AFFICHAGE_TERRITORY")
    observations = vmObservationsMaillesRepository.territoryObservationsMailles(connection)
    current_app.logger.debug("end AFFICHAGE_TERRITORY")

    session.close()
    return observations


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsMailleAndPoint/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsMailleAndPointAPI(cd_ref):
        """
        Retourne les observations d'un taxon en point et en maille

        :returns: dict ({'point:<GeoJson>', 'maille': 'GeoJson})
        """
        session = db.session
        observations = {
            "point": vmObservationsRepository.searchObservationsChilds(session, cd_ref),
            "maille": vmObservationsMaillesRepository.getObservationsMaillesChilds(
                session, cd_ref
            ),
        }
        session.close()
        return jsonify(observations)


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsPoint/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsPointAPI(cd_ref):
        session = db.session
        observations = vmObservationsRepository.searchObservationsChilds(session, cd_ref)
        session.close()
        return jsonify(observations)


@api.route("/observations/<int(signed=True):cd_ref>", methods=["GET"])
def getObservationsGenericApi(cd_ref: int):
    """[summary]

    Args:
        cd_ref (int): [description]

    Returns:
        [type]: [description]
    """
    session = db.session
    if current_app.config["AFFICHAGE_MAILLE"] or current_app.config["AFFICHAGE_TERRITOIRE_OBS"]:
        observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
            session,
            cd_ref,
            year_min=request.args.get("year_min"),
            year_max=request.args.get("year_max"),
        )
    else:
        observations = vmObservationsRepository.searchObservationsChilds(session, cd_ref)
    session.close()

    return jsonify(observations)


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observations/<id_area>/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsAreaTaxonAPI(id_area, cd_ref):
        connection = db.engine.connect()
        observations = vmObservationsRepository.getObservationTaxonArea(
            connection, id_area, cd_ref
        )
        connection.close()
        return jsonify(observations)


@api.route("/observationsMaille/<id_area>/<int(signed=True):cd_ref>", methods=["GET"])
def getObservationsAreaTaxonMailleAPI(id_area, cd_ref):
    connection = db.engine.connect()
    observations = vmObservationsMaillesRepository.getObservationsTaxonAreaMaille(
        connection, id_area, cd_ref
    )
    connection.close()
    return jsonify(observations)


@api.route("/area/<int(signed=True):id_area>", methods=["GET"])
def get_observations_area_api(id_area):
    connection = db.engine.connect()

    limit = request.args.get("limit")
    if current_app.config["AFFICHAGE_MAILLE"]:
        observations = vmObservationsMaillesRepository.getObservationsByArea(
            connection, str(id_area)
        )
    else:
        observations = vmObservationsRepository.getObservationsByArea(
            connection, id_area, limit
        )

    connection.close()
    return jsonify(observations)


@api.route("/photoGroup/<group>", methods=["GET"])
def getPhotosGroup(group):
    session = db.session
    photos = vmMedias.getPhotosGalleryByGroup(
        session,
        current_app.config["ATTR_MAIN_PHOTO"],
        current_app.config["ATTR_OTHER_PHOTO"],
        group,
    )
    return jsonify(photos)


@api.route("/photosGallery", methods=["GET"])
def getPhotosGallery():
    session = db.session
    photos = vmMedias.getPhotosGallery(
        session, current_app.config["ATTR_MAIN_PHOTO"], current_app.config["ATTR_OTHER_PHOTO"]
    )
    return jsonify(photos)


@api.route("/main_stat", methods=["GET"])
@cache.cached()
def main_stat():
    connection = db.engine.connect()
    return vmObservationsRepository.statIndex(connection)


@api.route("/rank_stat", methods=["GET"])
@cache.cached()
def rank_stat():
    connection = db.engine.connect()
    return jsonify(
        vmObservationsRepository.genericStat(connection, current_app.config["RANG_STAT"])
    )


@api.route("/area_chart_values/<id_area>", methods=["GET"])
def get_area_chart_valuesAPI(id_area):
    session = db.session
    connection = db.engine.connect()
    species_by_taxonomic_group = vmAreasRepository.get_species_by_taxonomic_group(
        session, id_area
    )
    observations_by_taxonomic_group = vmAreasRepository.get_nb_observations_taxonomic_group(
        session, id_area
    )
    nb_species_by_organism = vmOrganismsRepository.get_species_by_organism_on_area(
        connection, id_area
    )
    observations_by_organism = vmOrganismsRepository.get_nb_observations_by_organism_on_area(
        connection, id_area
    )

    session.close()
    connection.close()
    return jsonify(
        {
            "species_by_taxonomic_group": species_by_taxonomic_group,
            "observations_by_taxonomic_group": observations_by_taxonomic_group,
            "nb_species_by_organism": nb_species_by_organism,
            "observations_by_organism": observations_by_organism,
        }
    )
