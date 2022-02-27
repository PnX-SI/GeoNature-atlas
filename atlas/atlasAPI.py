# -*- coding:utf-8 -*-

from flask import jsonify, Blueprint, request, current_app

from atlas import utils
from atlas.modeles.repositories import (
    vmSearchTaxonRepository,
    vmObservationsRepository,
    vmObservationsMaillesRepository,
    vmMedias,
    vmGeoEntryRepository
)

api = Blueprint("api", __name__)


@api.route("/searchTaxon", methods=["GET"])
def searchTaxonAPI():
    session = utils.loadSession()
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmSearchTaxonRepository.listeTaxonsSearch(session, search, limit)
    session.close()
    return jsonify(results)


@api.route("/searchGeoEntry", methods=["GET"])
def searchGeoEntryAPI():
    session = utils.loadSession()
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmGeoEntryRepository.getGeoEntrySearch(session, search, limit)
    session.close()
    return jsonify(results)

@api.route("/getAllGeoEntry", methods=["GET"])
def getAllGeoEntryAPI():
    session = utils.loadSession()
    results = vmGeoEntryRepository.getAllGeoEntry(session)
    session.close()
    return jsonify(results)

if not current_app.config['AFFICHAGE_MAILLE']:
    @api.route("/observationsMailleAndPoint/<int:cd_ref>", methods=["GET"])
    def getObservationsMailleAndPointAPI(cd_ref):
        """
            Retourne les observations d'un taxon en point et en maille

            :returns: dict ({'point:<GeoJson>', 'maille': 'GeoJson})
        """
        session = utils.loadSession()
        observations = {
            "point": vmObservationsRepository.searchObservationsChilds(session, cd_ref),
            "maille": vmObservationsMaillesRepository.getObservationsMaillesChilds(
                session, cd_ref
            ),
        }
        session.close()
        return jsonify(observations)


@api.route("/observationsMaille/<int:cd_ref>", methods=["GET"])
def getObservationsMailleAPI(cd_ref, year_min=None, year_max=None):
    """
        Retourne les observations d'un taxon par maille (et le nombre d'observation par maille)

        :returns: GeoJson
    """
    session = utils.loadSession()
    observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
        session,
        cd_ref,
        year_min=request.args.get("year_min"),
        year_max=request.args.get("year_max"),
    )
    session.close()
    return jsonify(observations)




if not current_app.config['AFFICHAGE_MAILLE']:
    @api.route("/observationsPoint/<int:cd_ref>", methods=["GET"])
    def getObservationsPointAPI(cd_ref):
        session = utils.loadSession()
        observations = vmObservationsRepository.searchObservationsChilds(session, cd_ref)
        session.close()
        return jsonify(observations)



@api.route("/observations/<int:cd_ref>", methods=["GET"])
def getObservationsGenericApi(cd_ref: int):
    """[summary]

    Args:
        cd_ref (int): [description]

    Returns:
        [type]: [description]
    """
    session = utils.loadSession()
    observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
        session,
        cd_ref,
        year_min=request.args.get("year_min"),
        year_max=request.args.get("year_max"),
    ) if current_app.config['AFFICHAGE_MAILLE'] else vmObservationsRepository.searchObservationsChilds(session, cd_ref)
    session.close()
    return jsonify(observations)
    

if not current_app.config['AFFICHAGE_MAILLE']:
    @api.route("/observations/<geo_entry_id>/<int:cd_ref>", methods=["GET"])
    def getObservationsGeoEntryTaxonAPI(geo_entry_id, cd_ref):
        connection = utils.engine.connect()
        observations = vmObservationsRepository.getObservationTaxonGeoEntry(
            connection, geo_entry_id, cd_ref
        )
        connection.close()
        return jsonify(observations)


@api.route("/observationsMaille/<geo_entry_id>/<int:cd_ref>", methods=["GET"])
def getObservationsGeoEntryTaxonMailleAPI(geo_entry_id, cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsMaillesRepository.getObservationsTaxonGeoEntryMaille(
        connection, geo_entry_id, cd_ref
    )
    connection.close()
    return jsonify(observations)


@api.route("/photoGroup/<group>", methods=["GET"])
def getPhotosGroup(group):
    connection = utils.engine.connect()
    photos = vmMedias.getPhotosGalleryByGroup(
        connection,
        current_app.config["ATTR_MAIN_PHOTO"],
        current_app.config["ATTR_OTHER_PHOTO"],
        group,
    )
    connection.close()
    return jsonify(photos)


@api.route("/photosGallery", methods=["GET"])
def getPhotosGallery():
    connection = utils.engine.connect()
    photos = vmMedias.getPhotosGallery(
        connection,
        current_app.config["ATTR_MAIN_PHOTO"],
        current_app.config["ATTR_OTHER_PHOTO"],
    )
    connection.close()
    return jsonify(photos)


@api.route("/tes", methods=["GET"])
def test():
    connection = utils.engine.connect()
    photos = vmMedias.getPhotosGallery(
        connection,
        current_app.config["ATTR_MAIN_PHOTO"],
        current_app.config["ATTR_OTHER_PHOTO"],
    )
    connection.close()
    return jsonify(photos)