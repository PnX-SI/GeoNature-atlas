import pytest
from flask import url_for
from fixtures.main_fixtures import captured_templates

from atlas.configuration.config_schema import SecretSchemaConf
from atlas.tests.conftest import with_config


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
    ]
    for var in injected_context_vars:
        assert var in context

    # test secret fields are not pass to frontend config
    secret_fields = SecretSchemaConf().fields.keys()
    configuration = context["configuration"]
    for key, val in configuration.items():
        assert key not in secret_fields


def test_change_language_sets_session_and_persists(app, client, captured_templates):
    # Call change language route
    resp = client.get(url_for("main.change_language", lang_code="en"), follow_redirects=False)
    assert resp.status_code in (302, 303)

    # Session should have been set by the route
    with client.session_transaction() as sess:
        assert sess.get("language") == "en"

    # Calling another route (index) should keep the language in injected context
    client.get(url_for("main.index"))
    template, context = captured_templates[0]
    assert "current_language" in context
    assert context["current_language"] == "en"
