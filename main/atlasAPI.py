
# -*- coding:utf-8 -*-

from flask import json, Blueprint
from werkzeug.wrappers import Response
from . import utils
from modeles.repositories import (
    vmSearchTaxonRepository, vmObservationsRepository,
    vmObservationsMaillesRepository, vmMedias
)
from configuration import config

api = Blueprint('api', __name__)


@api.route('/searchTaxon/', methods=['GET'])
def searchTaxonAPI():
    session = utils.loadSession()
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    session.close()
    return Response(json.dumps(listeTaxonsSearch), mimetype='application/json')


@api.route('/observationsMailleAndPoint/<int:cd_ref>', methods=['GET'])
def getObservationsMailleAndPointAPI(cd_ref):
    connection = utils.engine.connect()
    observations = {
        'point': vmObservationsRepository.searchObservationsChilds(connection, cd_ref),
        'maille': vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref)
    }
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')


@api.route('/observationsMaille/<int:cd_ref>', methods=['GET'])
def getObservationsMailleAPI(cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref)
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')

@api.route('/observationsMailleLastObs/<int:cd_ref>',methods=['GET'])
def getObservationsMailleLastObsAPI(cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsMaillesRepository.getObservationsMaillesLastObsChilds(connection, cd_ref)
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')

@api.route('/observationsPoint/<int:cd_ref>', methods=['GET'])
def getObservationsPointAPI(cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsRepository.searchObservationsChilds(connection, cd_ref)
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')


@api.route('/observations/<insee>/<int:cd_ref>', methods=['GET'])
def getObservationsCommuneTaxonAPI(insee, cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsRepository.getObservationTaxonCommune(connection, insee, cd_ref)
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')


@api.route('/observationsMaille/<insee>/<int:cd_ref>', methods=['GET'])
def getObservationsCommuneTaxonMailleAPI(insee, cd_ref):
    connection = utils.engine.connect()
    observations = vmObservationsMaillesRepository.getObservationsTaxonCommuneMaille(connection, insee, cd_ref)
    connection.close()
    return Response(json.dumps(observations), mimetype='application/json')


@api.route('/photoGroup/<group>', methods=['GET'])
def getPhotosGroup(group):
    connection = utils.engine.connect()
    photos = vmMedias.getPhotosGalleryByGroup(connection, config.ATTR_MAIN_PHOTO, config.ATTR_OTHER_PHOTO, group)
    connection.close()
    return Response(json.dumps(photos), mimetype='application/json')


@api.route('/photosGallery', methods=['GET'])
def getPhotosGallery():
    connection = utils.engine.connect()
    photos = vmMedias.getPhotosGallery(connection, config.ATTR_MAIN_PHOTO, config.ATTR_OTHER_PHOTO)
    connection.close()
    return Response(json.dumps(photos), mimetype='application/json')
