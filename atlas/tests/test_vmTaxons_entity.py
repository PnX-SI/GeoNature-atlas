from types import SimpleNamespace

import pytest
from flask import Flask

from atlas.modeles.entities.vmTaxons import VmTaxons


@pytest.fixture
def app():
    app = Flask(__name__)
    app.config["SERVER_NAME"] = "test.atlas.local"
    return app


@pytest.fixture(autouse=True)
def db_session():
    """This unit test does not need the database session from conftest."""


@pytest.mark.parametrize(
    ("resize", "media_attrs", "expected_media"),
    [
        (
            True,
            {"id_media": 123},
            "https://taxhub.example/api/tmedias/thumbnail/123?h=80&width=80",
        ),
        (False, {"chemin": "image.jpg"}, "https://medias.example/image.jpg"),
        (False, {"url": "https://media.example/image.jpg"}, "https://media.example/image.jpg"),
    ],
)
def test_get_main_media_with_media(app, resize, media_attrs, expected_media):
    app.config.update(
        REDIMENSIONNEMENT_IMAGE=resize,
        TAXHUB_URL="https://taxhub.example",
        REMOTE_MEDIAS_URL="https://medias.example/",
    )
    taxon = SimpleNamespace(
        group2_inpn="Amphibiens",
        main_media=SimpleNamespace(
            id_media=media_attrs.get("id_media", 123),
            chemin=media_attrs.get("chemin"),
            url=media_attrs.get("url"),
        ),
    )

    with app.app_context():
        assert VmTaxons.get_main_media(taxon) == (expected_media, True)


def test_get_main_media_without_media(app):
    app.config.update(
        REDIMENSIONNEMENT_IMAGE=True,
        TAXHUB_URL="https://taxhub.example",
        REMOTE_MEDIAS_URL="https://medias.example/",
    )
    taxon = SimpleNamespace(
        group2_inpn="Hépatiques et Anthocérotes",
        main_media=None,
    )

    with app.app_context():
        assert VmTaxons.get_main_media(taxon) == (
            "/static/images/picto_Hepatiques_et_Anthocerotes.png",
            False,
        )


@pytest.mark.parametrize(
    ("resize", "expected_media", "expected_has_media"),
    [
        (True, "https://taxhub.example/api/tmedias/thumbnail/123?h=80&width=80", True),
        (False, "/static/images/picto_Chlorophytes_et_Charophytes.png", False),
    ],
)
def test_get_main_media_with_media_and_no_url_or_path(
    app, resize, expected_media, expected_has_media
):
    app.config.update(
        REDIMENSIONNEMENT_IMAGE=resize,
        TAXHUB_URL="https://taxhub.example",
        REMOTE_MEDIAS_URL="https://medias.example/",
    )
    taxon = SimpleNamespace(
        group2_inpn="Chlorophytes et Charophytes",
        main_media=SimpleNamespace(
            id_media=123,
            chemin=None,
            url=None,
        ),
    )

    with app.app_context():
        assert VmTaxons.get_main_media(taxon) == (expected_media, expected_has_media)
