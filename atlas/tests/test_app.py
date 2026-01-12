from flask import url_for
from fixtures.main_fixtures import captured_templates

from atlas.configuration.config_schema import SecretSchemaConf


def test_context_processor(app, client, captured_templates):
    client.get(url_for("main.index"))

    template, context = captured_templates[0]

    # test @app.context_processor for global vars in all app
    injected_context_vars = ["configuration", "translations", "now", "timedelta", "page_name"]
    for var in injected_context_vars:
        assert var in context

    # test secret fields are not pass to frontend config
    secret_fields = SecretSchemaConf().fields.keys()
    configuration = context["configuration"]
    for key, val in configuration.items():
        assert key not in secret_fields
