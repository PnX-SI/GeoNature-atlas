from datetime import date

import pytest
from geoalchemy2.elements import WKTElement
from werkzeug.datastructures import MultiDict

from atlas.modeles.entities.vmAreas import VmCorAreaSynthese
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.repositories import vmTaxonsRepository

# Import obs_with_area, taxon from fixtures.main_fixtures to ensure they are available for the tests
pytest_plugins = ("atlas.tests.fixtures.main_fixtures",)


@pytest.fixture
def taxon_variants(db_session):
    variants = [
        VmTaxons(
            cd_ref=223,
            regne="Animalia",
            phylum="Chordata",
            classe="Amphibia",
            ordre="Anura",
            famille="Ranidae",
            cd_taxsup=600,
            lb_nom="Rana temporaria",
            lb_auteur="Linnaeus",
            nom_complet="Rana temporaria Linnaeus",
            nom_complet_html="Rana temporaria Linnaeus",
            nom_valide="Rana temporaria",
            nom_vern="Grenouille rousse",
            patrimonial="oui",
            protection_stricte=False,
            menace=True,
            nb_obs=3,
            group1_inpn="Amphibiens",
            group2_inpn="Amphibiens",
            group3_inpn="Anoures",
            id_rang="ES",
            yearmin=2018,
            yearmax=2024,
        ),
        VmTaxons(
            cd_ref=224,
            regne="Animalia",
            phylum="Chordata",
            classe="Mammalia",
            ordre="Carnivora",
            famille="Mustelidae",
            cd_taxsup=500,
            lb_nom="Lutra lutra",
            lb_auteur="Linnaeus",
            nom_complet="Lutra lutra Linnaeus",
            nom_complet_html="Lutra lutra Linnaeus",
            nom_valide="Lutra lutra",
            nom_vern="Loutre d'Europe",
            patrimonial="non",
            protection_stricte=False,
            menace=False,
            nb_obs=1,
            group1_inpn="Mammifères",
            group2_inpn="Mammifères",
            group3_inpn="Carnivores",
            id_rang="ES",
            yearmin=2020,
            yearmax=2020,
        ),
    ]
    db_session.add_all(variants)
    db_session.flush()

    observations = [
        VmObservations(
            id_observation=223,
            dateobs=date(2024, 5, 1),
            observateurs="observer-a",
            altitude_retenue=100,
            cd_ref=223,
            the_geom_point=WKTElement("POINT(1 1)", srid=4326),
            geojson_point="{}",
            cd_sensitivity="1",
            id_dataset=1,
        ),
        VmObservations(
            id_observation=224,
            dateobs=date(2020, 5, 1),
            observateurs="observer-b",
            altitude_retenue=100,
            cd_ref=224,
            the_geom_point=WKTElement("POINT(1 1)", srid=4326),
            geojson_point="{}",
            cd_sensitivity="1",
            id_dataset=1,
        ),
    ]
    db_session.add_all(observations)
    db_session.flush()
    return variants


def test_getListTaxon_protected_filter(app, taxon, obs_with_area):
    """Insert an observation for the fixture taxon and verify
    that getListTaxon filtered with `protected` returns only
    taxa with `protection_stricte` == True."""

    params = MultiDict({"protected": "true"})
    res = vmTaxonsRepository.getListTaxon(params=params)

    assert res, "Expected at least one taxon returned"
    assert all(r.get("protection_stricte") is True for r in res)


def test_getListTaxon_filter_id_area(app, taxon, obs_with_area):
    """Insert an observation for the fixture taxon and verify
    that getListTaxon filtered with `protected` returns only
    taxa with `protection_stricte` == True."""

    # id_area 5 has no observation
    res = vmTaxonsRepository.getListTaxon(id_area=5)

    assert len(res) == 0

    # id_area 777777 has 1 observation
    res = vmTaxonsRepository.getListTaxon(id_area=777777)
    assert len(res) > 0


def test_getListTaxon_filter_id_area_with_id_terrirory(app, taxon_variants, db_session):
    """Add both observations (1 & 2) in a mesh area but only one (1) is
    in the territory (municipality) and in the mesh."""

    cas = VmCorAreaSynthese(
        id_synthese=223,
        id_area=1,
        id_type=25,
        type_code="COM",
        is_valid_for_display=True,
    )
    db_session.add(cas)

    cas = VmCorAreaSynthese(
        id_synthese=223,
        id_area=2,
        id_type=37,
        type_code="M5",
        is_valid_for_display=True,
    )
    db_session.add(cas)

    cas = VmCorAreaSynthese(
        id_synthese=224,
        id_area=2,
        id_type=37,
        type_code="M5",
        is_valid_for_display=True,
    )
    db_session.add(cas)
    db_session.flush()

    # id_area 2 is a mesh with only one obs 1 also in territory 1
    params = MultiDict({"territory_id": 1})
    res = vmTaxonsRepository.getListTaxon(id_area=2, params=params)
    assert len(res) == 1

    # If territory_id is not provided all obs should be returned
    res = vmTaxonsRepository.getListTaxon(id_area=2)
    assert len(res) == 2

    # If id_area = id territory all obs should be returned
    params = MultiDict({"territory_id": 2})
    res = vmTaxonsRepository.getListTaxon(id_area=2, params=params)
    assert len(res) == 2
