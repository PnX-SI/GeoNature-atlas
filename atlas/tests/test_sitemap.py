import pytest
from flask import url_for, current_app
from bs4 import BeautifulSoup

from fixtures.main_fixtures import taxon

### Test if routes are not 404 ###


def test_sitemap_ui(app, client, taxon):
    res = client.get(url_for("main.sitemap_ui"))
    assert res.status_code == 200


def test_sitemap_nb_title(app, client):
    res = client.get(url_for("main.sitemap_ui"))
    parsed_html = BeautifulSoup(res.data, features="html.parser").body.find("main")
    # nb_title_sitemap = 3, title => Pages statiques
    nb_title_sitemap = len(parsed_html.find_all("h2", class_="sitemap-section-title"))
    assert nb_title_sitemap == 3
