import sys

import pytest
from flask import url_for
from bs4 import BeautifulSoup
from atlas.app import create_app
from atlas.tests.conftest import with_config

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


@with_config(APPLICATION_ROOT="/atlas")
def test_sitemap_ui_with_application_root(client):
    """Test that sitemap_ui generates URLs with /atlas prefix and absolute URLs."""
    response = client.get(url_for("main.sitemap_ui"))
    assert response.status_code == 200

    soup = BeautifulSoup(response.data, "html.parser")
    links = [a["href"] for a in soup.find_all("a", class_="sitemap-link", href=True)]

    for link in links:
        assert "/atlas" in link


@with_config(APPLICATION_ROOT="/atlas")
def test_sitemap_with_application_root(client):
    """Test that sitemap generates URLs with /atlas prefix and absolute URLs."""
    response = client.get(url_for("main.sitemap"))
    assert response.status_code == 200

    soup = BeautifulSoup(response.data, "xml")
    urls = [loc.text.strip() for loc in soup.find_all("loc")]

    for url in urls:
        assert url.startswith("http://")
        assert "/atlas" in url


@pytest.fixture()
def client_without_photo_gallery(_db_setup):
    """
    Client d'une application creee avec la galerie photo desactivee.

    L'enregistrement de la route ``/photos`` est conditionnel et se joue a
    l'import de ``atlas.atlasRoutes``, donc une seule fois par processus.
    Le module est retire de ``sys.modules`` pour que ``create_app`` le
    reimporte et rejoue la condition, puis de nouveau apres le test pour ne
    pas influencer les suivants.
    """
    modules = ("atlas.atlasRoutes", "atlas.atlasAPI")

    def forget_routes():
        for module in modules:
            sys.modules.pop(module, None)

    forget_routes()
    app = create_app(config_overrides={"AFFICHAGE_GALERIE_PHOTO": False})
    app.testing = True
    app.config["SERVER_NAME"] = "test.atlas.local"  # required by url_for
    with app.app_context():
        yield app.test_client()
    forget_routes()


def test_sitemap_ui_without_photo_gallery(client_without_photo_gallery):
    """Le plan du site reste accessible quand la galerie photo est desactivee."""
    response = client_without_photo_gallery.get(url_for("main.sitemap_ui"))
    assert response.status_code == 200

    soup = BeautifulSoup(response.data, "html.parser")
    links = [a["href"] for a in soup.find_all("a", class_="sitemap-link", href=True)]
    assert not any(link.rstrip("/").endswith("/photos") for link in links)


def test_sitemap_without_photo_gallery(client_without_photo_gallery):
    """Le sitemap.xml reste accessible quand la galerie photo est desactivee."""
    response = client_without_photo_gallery.get(url_for("main.sitemap"))
    assert response.status_code == 200

    soup = BeautifulSoup(response.data, "xml")
    urls = [loc.text.strip() for loc in soup.find_all("loc")]
    assert not any(url.rstrip("/").endswith("/photos") for url in urls)
