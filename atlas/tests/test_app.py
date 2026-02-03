import pytest
from flask import url_for, g
from fixtures.main_fixtures import captured_templates
from bs4 import BeautifulSoup

from atlas.configuration.config_schema import SecretSchemaConf
from atlas.tests.conftest import with_config
from atlas.utils import get_locale


def test_context_processor(app, client, captured_templates):
    client.get(url_for("main.index"))

    template, context = captured_templates[0]

    # test @app.context_processor for global vars in all app
    injected_context_vars = [
        "configuration",
        "translations",
        "now",
        "timedelta",
        "page_name",
        "current_language",
        "current_url_prefix",
    ]
    for var in injected_context_vars:
        assert var in context

    # test secret fields are not pass to frontend config
    secret_fields = SecretSchemaConf().fields.keys()
    configuration = context["configuration"]
    for key, val in configuration.items():
        assert key not in secret_fields


# --- MULTILINGUAL TESTS ---
MULTILINGUAL_CONFIG = dict(
    MULTILINGUAL=True,
    DEFAULT_LANGUAGE="fr",
    AVAILABLE_LANGUAGES={
        "fr": {"flag_icon": "flag-icon-fr", "name": "Français"},
        "en": {"flag_icon": "flag-icon-gb", "name": "English"},
    },
)


@with_config(**MULTILINGUAL_CONFIG)
def test_access_with_and_without_lang_prefix(app, client):
    # Avec préfixe
    resp = client.get("/fr/")
    assert resp.status_code == 200
    resp = client.get("/en/")
    assert resp.status_code == 200
    # Sans préfixe
    resp = client.get("/")
    assert resp.status_code == 302


@with_config(**MULTILINGUAL_CONFIG)
def test_g_lang_code_on_lang_url(app, client):
    with app.test_request_context("/en/"):
        app.preprocess_request()
        assert hasattr(g, "lang_code")
        assert g.lang_code == "en"
    with app.test_request_context("/fr/"):
        app.preprocess_request()
        assert hasattr(g, "lang_code")
        assert g.lang_code == "fr"


@with_config(**MULTILINGUAL_CONFIG)
def test_lang_code_fallback_browser_or_default(app, client, monkeypatch):
    # Simule accept_languages.best_match qui retourne 'en'
    monkeypatch.setattr(
        "flask.Request.accept_languages",
        property(lambda self: type("Fake", (), {"best_match": lambda self, langs: "en"})()),
    )
    with app.test_request_context("/"):
        app.preprocess_request()
        assert hasattr(g, "lang_code")
        assert g.lang_code == "en"
    # Simule best_match retourne None -> fallback sur DEFAULT_LANGUAGE
    monkeypatch.setattr(
        "flask.Request.accept_languages",
        property(lambda self: type("Fake", (), {"best_match": lambda self, langs: None})()),
    )
    with app.test_request_context("/"):
        app.preprocess_request()
        assert hasattr(g, "lang_code")
        assert g.lang_code == "fr"


@with_config(**MULTILINGUAL_CONFIG)
def test_url_defaults_adds_lang_code_when_expected(app):
    # Register a route that expects lang_code
    @app.route("/<lang_code>/dummy")
    def dummy(lang_code):
        return lang_code

    # Register a route that does NOT expect lang_code
    @app.route("/no_lang")
    def no_lang():
        return "no_lang"

    # Use test_request_context to set g.lang_code
    with app.test_request_context("/fr/dummy"):
        from flask import g

        g.lang_code = "fr"
        # url_for should add lang_code automatically
        url = app.url_for("dummy")
        assert url == "/fr/dummy"

        # If we provide lang_code explicitly, it should use that
        url = app.url_for("dummy", lang_code="en")
        assert url == "/en/dummy"

        # For a route that does not expect lang_code, it should not add it
        url = app.url_for("no_lang")
        assert url == "/no_lang"


@with_config(**MULTILINGUAL_CONFIG)
def test_language_prefixed_url_application_in_template(app, client):
    """
    window.LANGUAGE_PREFIXED_URL_APPLICATION is used in JS for call API route
    the url must contain the prefixed language
    """
    response = client.get("/en/")
    soup = BeautifulSoup(response.data, "html.parser")
    # Cherche la variable JS dans le HTML
    assert "window.LANGUAGE_PREFIXED_URL_APPLICATION" in str(response.data)
    script_tag = soup.find(attrs={"data-qa": "test-lang"})
    assert "/en" in script_tag.text


@with_config(MULTILINGUAL=False, DEFAULT_LANGUAGE="fr")
def test_get_locale_not_multilingual_returns_default(app):
    with app.test_request_context("/"):
        assert get_locale() == "fr"


@with_config(**MULTILINGUAL_CONFIG)
def test_canonical_and_alternate_links_in_layout(app, client):
    resp = client.get("/en/")
    soup = BeautifulSoup(resp.data, "html.parser")

    # Get base URL from the test client
    base_url = "http://test.atlas.local"  # this url is set in conftest

    # Check alternates
    alternates = soup.find_all("link", attrs={"rel": "alternate", "data-qa": "alternate-test"})
    assert len(alternates) == len(MULTILINGUAL_CONFIG["AVAILABLE_LANGUAGES"])
    for alt in alternates:
        lang = alt["hreflang"]
        expected_url = f"{base_url}/{lang}/"
        assert alt["href"].startswith(expected_url)

    # Check canonical
    canonical = soup.find("link", attrs={"rel": "canonical"})
    assert canonical is not None
    expected_canonical = f"{base_url}/en/"
    assert canonical["href"].startswith(expected_canonical)
