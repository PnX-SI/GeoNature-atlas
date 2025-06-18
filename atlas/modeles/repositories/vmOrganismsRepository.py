import json

from geojson import Feature, FeatureCollection
from sqlalchemy.sql import func, or_, select, distinct

from atlas.modeles.entities.vmAreas import VmAreas, VmAreaStatsOrganism
from atlas.modeles.entities.tCorDatasetActor import TCorDatasetActor
from atlas.modeles.entities.tBibOrganismes import TBibOrganismes
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmOrganisms import VmOrganisms
from atlas.modeles.entities.vmTaxref import VmTaxref
from atlas.env import db


def statOrganism(id_organism):
    # Fiche organism
    req = (
        select(
            func.count(distinct(VmOrganisms.cd_ref)).label("nb_taxons"),
            func.sum(VmOrganisms.nb_observations).label("nb_obs"),
            VmOrganisms.nom_organism,
            VmOrganisms.url_organism,
            VmOrganisms.url_logo,
            VmOrganisms.adresse_organism,
            VmOrganisms.cp_organism,
            VmOrganisms.ville_organism,
            VmOrganisms.tel_organism,
            VmOrganisms.email_organism,
        )
        .filter(VmOrganisms.id_organism == id_organism)
        .group_by(
            VmOrganisms.nom_organism,
            VmOrganisms.url_organism,
            VmOrganisms.url_logo,
            VmOrganisms.adresse_organism,
            VmOrganisms.cp_organism,
            VmOrganisms.ville_organism,
            VmOrganisms.tel_organism,
            VmOrganisms.email_organism,
        )
    )
    results = db.session.execute(req).all()
    StatsOrga = dict()
    for r in results:
        StatsOrga = {
            "nb_taxons": r.nb_taxons,
            "nb_obs": r.nb_obs,
            "nom_organism": r.nom_organism,
            "url_organism": r.url_organism,
            "url_logo": r.url_logo,
            "adresse_organism": r.adresse_organism,
            "cp_organism": r.cp_organism,
            "ville_organism": r.ville_organism,
            "tel_organism": r.tel_organism,
            "email_organism": r.email_organism,
        }

    return StatsOrga


def topObsOrganism(id_organism):
    # Stats avancées organism
    req = (
        select(VmOrganisms.cd_ref, VmOrganisms.nb_observations.label("nb_obs_taxon"))
        .filter(VmOrganisms.id_organism == id_organism)
        .order_by(VmOrganisms.nb_observations.desc())
        .limit(3)
    )
    results = db.session.execute(req).all()
    topSpecies = list()
    for r in results:
        temp = {"cd_ref": r.cd_ref, "nb_obs_taxon": r.nb_obs_taxon}
        topSpecies.append(temp)
    return topSpecies


def getListOrganism(cd_ref):
    # Fiche espèce : Liste des organismes pour un taxon
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    nb_observations = func.sum(VmOrganisms.nb_observations).label("nb_observations")
    req = (
        select(
            nb_observations,
            VmOrganisms.id_organism,
            VmOrganisms.nom_organism,
            VmOrganisms.url_organism,
            VmOrganisms.url_logo,
        )
        .filter(or_(VmOrganisms.cd_ref.in_(childs_ids), VmOrganisms.cd_ref == cd_ref))
        .group_by(
            VmOrganisms.id_organism,
            VmOrganisms.nom_organism,
            VmOrganisms.url_organism,
            VmOrganisms.url_logo,
        )
        .order_by(nb_observations.desc())
    )
    results = db.session.execute(req).all()
    ListOrganism = list()
    for r in results:
        temp = {
            "nb_observation": r.nb_observations,
            "id_organism": r.id_organism,
            "nom_organism": r.nom_organism,
            "url_organism": r.url_organism,
            "url_logo": r.url_logo,
        }
        ListOrganism.append(temp)
    return ListOrganism


def getTaxonRepartitionOrganism(id_organism):
    # Fiche organism : réparition du type d'observations
    req = (
        select(func.sum(VmOrganisms.nb_observations).label("nb_obs_group"), VmTaxref.group2_inpn)
        .join(VmTaxref, VmTaxref.cd_nom == VmOrganisms.cd_ref)
        .filter(VmOrganisms.id_organism == id_organism)
        .group_by(VmTaxref.group2_inpn, VmOrganisms.id_organism)
    )
    results = db.session.execute(req).all()
    ListGroup = list()
    for r in results:
        temp = {"group2_inpn": r.group2_inpn, "nb_obs_group": int(r.nb_obs_group)}
        ListGroup.append(temp)
    return ListGroup


def get_nb_organism_on_area(id_area):
    req = (
        select(
            func.count(distinct(VmOrganisms.nom_organism)).label("nb_organism"),
        )
        .select_from(VmObservations)
        .join(TCorDatasetActor, VmObservations.id_dataset == TCorDatasetActor.id_dataset)
        .join(VmOrganisms, VmOrganisms.id_organism == TCorDatasetActor.id_organism)
        .join(VmAreas, func.ST_Intersects(VmObservations.the_geom_point, VmAreas.the_geom))
        .filter(VmAreas.id_area == id_area)
    )
    results = db.session.execute(req).all()
    result = dict()
    for r in results:
        result = r.nb_organism
    return result


def get_nb_species_by_organism_on_area(id_area):
    req = (
        select(
            func.count(distinct(VmObservations.cd_ref)).label("nb_species"),
            VmOrganisms.nom_organism,
        )
        .join(TCorDatasetActor, TCorDatasetActor.id_dataset == VmObservations.id_dataset)
        .join(VmOrganisms, VmOrganisms.id_organism == TCorDatasetActor.id_organism)
        .join(VmAreas, func.ST_intersects(VmObservations.the_geom_point, VmAreas.the_geom))
        .filter(VmAreas.id_area == id_area)
        .group_by(VmOrganisms.nom_organism)
        .order_by(VmOrganisms.nom_organism)
    )
    results = db.session.execute(req).all()
    list_species_by_organism = list()
    for r in results:
        temp = {"nb": r.nb_species, "label": r.nom_organism}
        list_species_by_organism.append(temp)
    return list_species_by_organism


def get_nb_observations_by_organism_on_area(id_area):
    req = (
        select(
            func.count(VmObservations.id_observation).label("nb_observations"),
            TBibOrganismes.nom_organisme,
        )
        .join(TCorDatasetActor, TCorDatasetActor.id_dataset == VmObservations.id_dataset)
        .join(TBibOrganismes, TBibOrganismes.id_organisme == TCorDatasetActor.id_organism)
        .join(VmAreas, func.St_Intersects(VmObservations.the_geom_point, VmAreas.the_geom))
        .filter(VmAreas.id_area == id_area)
        .group_by(TBibOrganismes.nom_organisme)
        .order_by(TBibOrganismes.nom_organisme)
    )
    results = db.session.execute(req).all()
    list_observations_by_organism = list()
    for r in results:
        temp = {"nb": r.nb_observations, "label": r.nom_organisme}
        list_observations_by_organism.append(temp)
    return list_observations_by_organism


def get_species_by_organism_on_area(id_area):
    req = select(VmAreaStatsOrganism.nb_species, VmAreaStatsOrganism.nom_organism).filter(
        VmAreaStatsOrganism.id_area == id_area
    )
    results = db.session.execute(req).all()
    list_species_by_organism = list()
    for r in results:
        temp = {"nb": r.nb_species, "label": r.nom_organism}
        list_species_by_organism.append(temp)
    return list_species_by_organism


def get_nb_observations_by_organism_on_area(id_area):
    req = select(VmAreaStatsOrganism.nb_obs, VmAreaStatsOrganism.nom_organism).filter(
        VmAreaStatsOrganism.id_area == id_area
    )
    results = db.session.execute(req).all()
    list_species_by_organism = list()
    for r in results:
        temp = {"nb": r.nb_obs, "label": r.nom_organism}
        list_species_by_organism.append(temp)
    return list_species_by_organism
