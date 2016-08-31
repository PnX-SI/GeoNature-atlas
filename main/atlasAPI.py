from flask import jsonify, json, Blueprint
from werkzeug.wrappers import Response
from . import utils
from modeles.repositories import vmSearchTaxonRepository, vmObservationsRepository, vmObservationsMaillesRepository

api = Blueprint('api', __name__)


@api.route('/searchTaxon/', methods=['GET'])
def searchTaxon():
    session = utils.loadSession()
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    session.close()
    return Response(json.dumps(listeTaxonsSearch), mimetype='application/json')

@api.route('/observationsMailleAndPoint/<int:cd_ref>', methods=['GET'])
def getObservationsMailleAndPoint(cd_ref):
	connection = utils.engine.connect()
	observations = {'point': vmObservationsRepository.searchObservationsChilds(connection, cd_ref),\
	'maille' : vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref)}
	connection.close()
	return Response(json.dumps(observations), mimetype='application/json')


	
@api.route('/observationsMaille/<int:cd_ref>', methods=['GET'])
def getObservationsMaille(cd_ref):
	connection = utils.engine.connect()
	observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref)
	connection.close()
	return Response(json.dumps(observations), mimetype='application/json')	

@api.route('/observationsPoint/<int:cd_ref>', methods=['GET'])
def getObservationsPoint(cd_ref):
	connection = utils.engine.connect()
	observations = vmObservationsRepository.searchObservationsChilds(connection, cd_ref)
	connection.close()
	return Response(json.dumps(observations), mimetype='application/json')	


