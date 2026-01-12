import pytest
from flask import url_for, current_app
from bs4 import BeautifulSoup
from unittest.mock import patch

from sqlalchemy import select
from fixtures.main_fixtures import taxon, TemplateData, captured_templates
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.env import db
from atlas.tests.conftest import with_config


@pytest.fixture
def fake_altitude(mocker):
    # hack : pour l'instant on a pas d'altitude dans la base dans le contexte des tests
    mocker.patch(
        "atlas.modeles.repositories.vmAltitudesRepository.getAltitudesChilds", return_value=[]
    )


@pytest.fixture
def template_data(client, captured_templates, taxon, fake_altitude):

    VmTaxons.query.get(taxon.cd_ref)
    response = client.get(url_for("main.ficheEspece", cd_nom=taxon.cd_ref))
    template, context = captured_templates[0]
    soup = BeautifulSoup(response.data, "html.parser")
    return TemplateData(soup=soup, context=context)


class TestTemplates:
    @with_config(ORGANISM_MODULE=False)
    def test_module_observers_enabled(self, app, template_data):
        element = template_data.soup.find(attrs={"data-qa": "organism-module-tab"})
        assert element is None

    @with_config(ORGANISM_MODULE=True)
    def test_module_observers_disabled(self, app, template_data):
        element = template_data.soup.find(attrs={"data-qa": "organism-module-tab"})
        assert element is not None
