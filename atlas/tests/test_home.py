import pytest
from flask import url_for, current_app
from bs4 import BeautifulSoup

from fixtures.main_fixtures import captured_templates, TemplateData
from atlas.tests.conftest import with_config

### Test if routes are not 404 ###


@pytest.fixture
def template_data(client, captured_templates):
    response = client.get(
        url_for(
            "main.index",
        )
    )
    template, context = captured_templates[0]
    soup = BeautifulSoup(response.data, "html.parser")
    return TemplateData(soup=soup, context=context)


def test_index(app, client):
    res = client.get(url_for("main.index"))
    assert res.status_code == 200


@with_config(
    STATIC_PAGES={
        "presentation": {
            "template": "static/custom/templates/presentation.html",
            "title": "Présentation de l'atlas",
            "short_title": "Présentation de l'atlas",
            "picto": "fa-question-circle",
            "order": 0,
        },
        "autre-page": {
            "template": "static/custom/templates/presentation.html",
            "title": "Autre page",
            "short_title": "Autre page",
            "picto": "fa-question-circle",
            "order": 1,
        },
        "pne": {
            "url": "https://www.ecrins-parcnational.fr/",
            "title": "Parc national des Ecrins",
            "short_title": "Parc national des Ecrins",
            "customized_picto": "sample.external-website.png",
            "picto_height": 16,
            "order": 2,
        },
    },
    AFFICHAGE_LABEL_SIDEBAR=True,
)
def test_static_pages(app, template_data):
    static_pages = template_data.soup.find_all(attrs={"data-qa": "static-pages"})
    assert len(static_pages) == 3
    # TODO : check short title
