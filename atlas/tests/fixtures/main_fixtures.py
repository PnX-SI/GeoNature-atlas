from dataclasses import dataclass
from copy import deepcopy

from datetime import date

import pytest
from bs4 import BeautifulSoup

from flask import template_rendered
from geoalchemy2.elements import WKTElement

from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmTaxref import VmTaxref
from atlas.modeles.entities.vmAreas import (
    VmAreas,
    VmAreasWithObs,
    VmBibAreasTypes,
    VmCorAreaSynthese,
)
from atlas.env import db


@dataclass
class TemplateData:
    soup: BeautifulSoup
    context: dict


@pytest.fixture
def captured_templates(app):
    recorded = []

    def record(sender, template, context, **extra):
        recorded.append((template, context))

    template_rendered.connect(record, app)
    try:
        yield recorded
    finally:
        template_rendered.disconnect(record, app)


@pytest.fixture
def taxon(db_session):
    cd_ref = 222

    taxref = VmTaxref(
        cd_nom=cd_ref,
        id_statut="A",
        id_habitat=1,
        id_rang="1",
        regne="Animalia",
        phylum="Chordata",
        classe="Amphibia",
        ordre="Anura",
        famille="Bombinatoridae",
        sous_famille="",
        tribu="",
        cd_taxsup=500,
        cd_sup=500,
        cd_ref=cd_ref,
        lb_nom="Bombina variagata",
        lb_auteur="Linné",
        nom_complet="Bombina variagata Linné",
        nom_complet_html="Bombina variagata <i>Linné</i>",
        nom_valide="Bombina variagata",
        nom_vern="Sonneur à ventre jaune",
        nom_vern_eng="Yellow-bellied toad",
        group1_inpn="Amphibiens",
        group2_inpn="Amphibiens",
        group3_inpn="Amphibiens",
        url="https://inpn.mnhn.fr/espece/cd_nom/215",
    )

    vm_taxons = VmTaxons(
        cd_ref=cd_ref,
        regne="Animalia",
        phylum="Chordata",
        classe="Amphibia",
        ordre="Anura",
        famille="Bombinatoridae",
        cd_taxsup=500,
        lb_auteur="Linné",
        lb_nom="Bombina variagata",
        nom_complet="Bombina variagata Linné ...",
        nom_complet_html="Bombina variagata Linné ...",
        nom_valide="Bombina variagata",
        nom_vern="Sonneur à ventre jaune",
        patrimonial="oui",
        protection_stricte=True,
        menace=True,
        nb_obs=5,
        group2_inpn="Amphibiens",
        group1_inpn="Amphibiens",
        group3_inpn="Amphibiens",
        id_rang="1",
        yearmin=2010,
        yearmax=2022,
    )

    db_session.add(taxref)
    db_session.add(vm_taxons)
    db_session.flush()

    return vm_taxons


@pytest.fixture(scope="function")
def vm_areas_with_obs_data():
    # Ajoute des données de test, ne supprime ni ne nettoie la table
    area1 = VmAreasWithObs(id_area=101, area_name="Test Area", id_type=10, type_code="COMMUNE")
    area2 = VmAreasWithObs(
        id_area=102, area_name="Autre Territoire", id_type=11, type_code="DEPARTEMENT"
    )
    db.session.add_all([area1, area2])
    db.session.commit()
    return [area1, area2]
    # Pas de suppression ici (conformément aux instructions)


@pytest.fixture
def areas_by_type(db_session):
    """Une commune et un département, pour jouer sur TYPE_TERRITOIRE_SHEET."""
    geom = WKTElement("MULTIPOLYGON(((0 0,0 1,1 1,1 0,0 0)))", srid=4326)
    areas = {}
    for id_type, type_code, type_name in ((201, "COM", "Communes"), (202, "DEP", "Départements")):
        db_session.add(
            VmBibAreasTypes(
                id_type=id_type, type_code=type_code, type_name=type_name, type_desc=""
            )
        )
        areas[type_code] = VmAreas(
            id_area=id_type,
            area_code=str(id_type),
            area_name=f"Zonage {type_code}",
            id_type=id_type,
            the_geom=geom,
            area_geojson="{}",
            description="",
        )
    db_session.add_all(areas.values())
    db_session.flush()
    return areas


@pytest.fixture
def obs_with_area(db_session, taxon):
    """Crée une observation liée au `taxon` fixture et ajoute une
    entrée `VmCorAreaSynthese`"""

    from atlas.modeles.entities.vmObservations import VmObservations

    obs = VmObservations(
        id_observation=1,
        dateobs=date.today(),
        observateurs="tester",
        altitude_retenue=10,
        cd_ref=taxon.cd_ref,
        the_geom_point=WKTElement("POINT(1 1)", srid=4326),
        geojson_point="{}",
        cd_sensitivity=1,
        id_dataset=1,
    )
    db_session.add(obs)

    obs = VmObservations(
        id_observation=2,
        dateobs=date.today(),
        observateurs="tester",
        altitude_retenue=10,
        cd_ref=taxon.cd_ref,
        the_geom_point=WKTElement("POINT(2 2)", srid=4326),
        geojson_point="{}",
        cd_sensitivity=1,
        id_dataset=1,
    )
    db_session.add(obs)

    synth = VmCorAreaSynthese(
        id_synthese=1,
        id_area=777777,
        id_type=1,
        type_code="COMMUNE",
        is_valid_for_display=True,
    )
    db_session.add(synth)
    db_session.flush()
    return obs
