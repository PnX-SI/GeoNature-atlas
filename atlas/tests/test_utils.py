from atlas.utils import get_locale
from atlas.tests.conftest import with_config


@with_config(MULTILINGUAL=False, DEFAULT_LANGUAGE="fr")
def test_get_locale_not_multilingual_returns_default(app):
    with app.test_request_context("/"):
        assert get_locale() == "fr"


@with_config(
    MULTILINGUAL=True,
    AVAILABLE_LANGUAGES={"fr": {}, "en": {}},
    DEFAULT_LANGUAGE="fr",
)
def test_get_locale_session_language_valid(app, client):

    # register a simple endpoint that returns the computed locale
    def _locale():
        return get_locale()

    app.add_url_rule("/_locale_valid", "_locale_valid", _locale)

    with client.session_transaction() as sess:
        sess["language"] = "en"

    r = client.get("/_locale_valid")
    assert r.data.decode() == "en"


@with_config(
    MULTILINGUAL=True,
    AVAILABLE_LANGUAGES={"fr": {}, "en": {}},
    DEFAULT_LANGUAGE="fr",
)
def test_get_locale_session_language_invalid_fallback_accept_language(app, client):
    with client.session_transaction() as sess:
        sess["language"] = "xx"

    r = client.get("/", headers={"Accept-Language": "en-US,en;q=0.9"})
    with app.test_request_context("/", headers={"Accept-Language": "en-US,en;q=0.9"}):
        assert get_locale() == "en"


@with_config(
    MULTILINGUAL=True,
    AVAILABLE_LANGUAGES={"fr": {}, "en": {}},
    DEFAULT_LANGUAGE="fr",
)
def test_get_locale_no_session_no_match_returns_default(app, client):
    r = client.get("/", headers={"Accept-Language": "es"})
    with app.test_request_context("/", headers={"Accept-Language": "es"}):
        assert get_locale() == "fr"
