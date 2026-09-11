import pytest
from flask import url_for
from werkzeug.exceptions import NotFound

from fixtures.main_fixtures import areas_by_type
from atlas.modeles.repositories import vmAreasRepository
from atlas.tests.conftest import with_config


# TYPE_TERRITOIRE_SHEET vaut ["COM"] par défaut


def test_published_type(app, areas_by_type):
    assert vmAreasRepository.assertAreaPublished(areas_by_type["COM"].id_area) is None


def test_unpublished_type(app, areas_by_type):
    with pytest.raises(NotFound):
        vmAreasRepository.assertAreaPublished(areas_by_type["DEP"].id_area)


@with_config(TYPE_TERRITOIRE_SHEET=[])
def test_no_type_publishes_nothing(app, areas_by_type):
    for area in areas_by_type.values():
        with pytest.raises(NotFound):
            vmAreasRepository.assertAreaPublished(area.id_area)


@pytest.mark.parametrize(
    "endpoint",
    ["main.area", "api.get_area_chart_valuesAPI", "api.get_taxon_list", "api.get_taxon_list_json"],
)
def test_area_routes_are_404(client, areas_by_type, endpoint):
    url = url_for(endpoint, id_area=areas_by_type["DEP"].id_area)
    assert client.get(url).status_code == 404
