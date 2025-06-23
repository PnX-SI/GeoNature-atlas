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
from atlas.env import cache

api = Blueprint("api", __name__)


@api.route("/searchTaxon", methods=["GET"])
def searchTaxonAPI():
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmSearchTaxonRepository.listeTaxonsSearch(search, limit)
    return jsonify(results)


@api.route("/searchArea", methods=["GET"])
def searchAreaAPI():
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmAreasRepository.searchAreas(search, limit)
    return jsonify(results)


@api.route("/observationsMailleTerritory", methods=["GET"])
def getMailleHomeTerritory():
    """
    Retourne les mailles de tout le territoire
    """
    current_app.logger.debug("start AFFICHAGE_TERRITORY")
    observations = vmObservationsMaillesRepository.territoryObservationsMailles()
    current_app.logger.debug("end AFFICHAGE_TERRITORY")

    return observations


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsMailleAndPoint/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsMailleAndPointAPI(cd_ref):
        """
        Retourne les observations d'un taxon en point et en maille

        :returns: dict ({'point:<GeoJson>', 'maille': 'GeoJson})
        """
        observations = {
            "point": vmObservationsRepository.searchObservationsChilds(cd_ref),
            "maille": vmObservationsMaillesRepository.getObservationsMaillesChilds(
                cd_ref
            ),
        }
        return jsonify(observations)


@api.route("/observationsMaille/<int(signed=True):cd_ref>", methods=["GET"])
def getObservationsMailleAPI(cd_ref):
    """
    Retourne les observations d'un taxon par maille (et le nombre d'observation par maille)

    :returns: GeoJson
    """
    observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
        cd_ref,
        year_min=request.args.get("year_min"),
        year_max=request.args.get("year_max"),
    )
    return jsonify(observations)


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsPoint/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsPointAPI(cd_ref):
        observations = vmObservationsRepository.searchObservationsChilds(cd_ref)
        return jsonify(observations)


@api.route("/observations/<int(signed=True):cd_ref>", methods=["GET"])
def getObservationsGenericApi(cd_ref: int):
    """[summary]

    Args:
        cd_ref (int): [description]

    Returns:
        [type]: [description]
    """
    if current_app.config["AFFICHAGE_TERRITOIRE_OBS"]:
        observations = vmObservationsMaillesRepository.getObservationsMaillesTerritorySpecies(
            cd_ref,
        )
    elif current_app.config["AFFICHAGE_MAILLE"]:
        observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
            cd_ref,
            year_min=request.args.get("year_min"),
            year_max=request.args.get("year_max"),
        )
    else:
        observations = vmObservationsRepository.searchObservationsChilds(cd_ref)

    return jsonify(observations)


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observations/<id_area>/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsAreaTaxonAPI(id_area, cd_ref):
        observations = vmObservationsRepository.getObservationTaxonArea(id_area, cd_ref)
        return jsonify(observations)


@api.route("/observationsMaille/<id_area>/<int(signed=True):cd_ref>", methods=["GET"])
def getObservationsAreaTaxonMailleAPI(id_area, cd_ref):
    observations = vmObservationsMaillesRepository.getObservationsTaxonAreaMaille(
        id_area, cd_ref
    )
    return jsonify(observations)


@api.route("/area/<int(signed=True):id_area>", methods=["GET"])
def get_observations_area_api(id_area):

    limit = request.args.get("limit")
    if current_app.config["AFFICHAGE_MAILLE"]:
        observations = vmObservationsMaillesRepository.getObservationsByArea(
            str(id_area)
        )
    else:
        observations = vmObservationsRepository.getObservationsByArea(id_area, limit)

    return jsonify(observations)


@api.route("/photoGroup/<group>", methods=["GET"])
def getPhotosGroup(group):
    photos = vmMedias.getPhotosGalleryByGroup(
        current_app.config["ATTR_MAIN_PHOTO"],
        current_app.config["ATTR_OTHER_PHOTO"],
        group,
    )
    return jsonify(photos)


@api.route("/photosGallery", methods=["GET"])
def getPhotosGallery():
    photos = vmMedias.getPhotosGallery(
        current_app.config["ATTR_MAIN_PHOTO"], current_app.config["ATTR_OTHER_PHOTO"]
    )
    return jsonify(photos)


@api.route("/main_stat", methods=["GET"])
@cache.cached()
def main_stat():
    return vmObservationsRepository.statIndex()


@api.route("/rank_stat", methods=["GET"])
@cache.cached()
def rank_stat():
    return jsonify(vmObservationsRepository.genericStat(current_app.config["RANG_STAT"]))


@api.route("/area_chart_values/<id_area>", methods=["GET"])
def get_area_chart_valuesAPI(id_area):
    species_by_taxonomic_group = vmAreasRepository.get_species_by_taxonomic_group(id_area)
    observations_by_taxonomic_group = vmAreasRepository.get_nb_observations_taxonomic_group(
        id_area
    )
    nb_species_by_organism = vmOrganismsRepository.get_species_by_organism_on_area(
        id_area
    )
    observations_by_organism = vmOrganismsRepository.get_nb_observations_by_organism_on_area(
        id_area
    )

    return jsonify(
        {
            "species_by_taxonomic_group": species_by_taxonomic_group,
            "observations_by_taxonomic_group": observations_by_taxonomic_group,
            "nb_species_by_organism": nb_species_by_organism,
            "observations_by_organism": observations_by_organism,
        }
    )
