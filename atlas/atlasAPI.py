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
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmSearchTaxonRepository.searchTaxons(search, limit)
    return jsonify(results)


@api.route("/searchArea", methods=["GET"])
def searchAreaAPI():
    search = request.args.get("search", "")
    limit = request.args.get("limit", 50)
    results = vmAreasRepository.searchAreas(search, limit)
    return jsonify(results)



if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsMailleAndPoint/<int(signed=True):cd_ref>", methods=["GET"])
    def getObservationsMailleAndPointAPI(cd_ref):
        """
        Retourne les observations d'un taxon en point et en maille

        :returns: dict ({'point:<GeoJson>', 'maille': 'GeoJson})
        """
        observations = {
            "point": vmObservationsRepository.getObservationsChilds(filters={"cd_ref": cd_ref}),
            "maille": vmObservationsMaillesRepository.getObservationsMaillesChilds(
                filters={"cd_ref": cd_ref}
            ),
        }
        return jsonify(observations)



@api.route("/observationsMaille", methods=["GET"])
def getObservationsMailleAPI():
    """
    Retourne un geojson avec comme geométrie la maille de floutage (ou la maille par défaut de l'atlas si non sensible) des observations
    Le geojson contient les paramètre suivant :
        - id_maille
        - type_code : le type de maille à la laquelle la géométrie a floutée
        - last_obs_year : l'année à laquel la dernière observation a été faite dans la maille
        - obs_nbr : le nombre d'observation dans la maille
        - taxons (optionnel: si with taxon est True) : une liste des taxons dans la maille
    Parameters
    ----------
    query string:
        - year_min / year_max : filtre les observation dans des bornes d'année
        - cd_ref : renvoie que les observation de ce taxon et de ces enfants
        - id_area : renvoie uniquement les observations présente dans l'aire demandée
    with_taxons : bool, optional
        - Permet d'ajouter la liste des taxon d'une maille au Geojson

    :returns: GeoJson
    """
    observations = vmObservationsMaillesRepository.getObservationsMaillesChilds(
        filters=request.args,
        with_taxons=request.args.get("with_taxons", False)
    )
    return jsonify(observations)


if not current_app.config["AFFICHAGE_MAILLE"]:

    @api.route("/observationsPoint", methods=["GET"])
    def getObservationsPointAPI():
        """
        Retourne un geojson des observations en point
        Le geojson contient les propriétés présentes dans VMObservation
        + taxon (optionnel: si with taxon est True) : le taxon de l'observation sous forme 'nom_vern | lb_nom'

        Parameters
        ----------
        filters : dict, optional
            dictionnaire des filtres de la query
            Filtres disponible :
                - year_min / year_max : filtre les observation dans des bornes d'année
                - cd_ref : renvoie que les observation de ce taxon et de ces enfants
                - id_area : renvoie uniquement les observations présente dans l'aire demandée
                - limit : limite le nombre de résultat

        Returns
        -------
        Geosjon
        """
        observations = vmObservationsRepository.getObservationsChilds(
            request.args,
            with_taxons=request.args.get("with_taxons", False)
        )
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
    return jsonify(
        vmObservationsRepository.genericStat(current_app.config["RANG_STAT"])
    )


@api.route("/area_chart_values/<id_area>", methods=["GET"])
def get_area_chart_valuesAPI(id_area):
    stats = vmAreasRepository.getStatsByArea(id_area)
    nb_species = stats["nb_species"]
    nb_threatened_species = stats["nb_taxon_threatened"]

    species_by_taxonomic_group = vmAreasRepository.get_species_by_taxonomic_group(
        id_area
    )
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
            "nb_species": nb_species,
            "nb_threatened_species": nb_threatened_species,
        }
    )
