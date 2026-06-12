import os
import copy
from datetime import datetime, timedelta
from flask import Flask, request, session, redirect, url_for, g
from flask_compress import Compress
from flask_sqlalchemy import SQLAlchemy
from werkzeug.middleware.proxy_fix import ProxyFix
from werkzeug.middleware.shared_data import SharedDataMiddleware
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from werkzeug.wrappers import Response

from atlas.configuration.config_parser import config, public_config
from atlas.configuration.config_schema import AtlasConfig, SecretSchemaConf
from atlas.env import (
    atlas_static_folder,
    atlas_template_folder,
    atlas_config_file_path,
    atlas_translations_folder,
    db,
    cache,
    babel,
)
from atlas.utils import (
    get_locale,
    get_tranlated_labels,
    multilingual_utils,
    get_current_url_prefix,
)

compress = Compress()


def create_app(config_overrides=None):
    """
    renvoie une instance de l'app Flask
    """
    app = Flask(__name__, template_folder=atlas_template_folder, static_folder=atlas_static_folder)
    app.config.update(config)
    # config overrides are used in tests
    if config_overrides:
        app.config.update(config_overrides)

    db.init_app(app)
    cache.init_app(
        app,
        config={
            "CACHE_TYPE": "SimpleCache",
            "CACHE_DEFAULT_TIMEOUT": app.config["CACHE_TIMEOUT"],
        },
    )

    app.config["BABEL_TRANSLATION_DIRECTORIES"] = (
        f"{atlas_translations_folder};translations;static/custom/translations_override"
    )
    # app.config["BABEL_TRANSLATION_DIRECTORIES"] = "trucquexistepas"

    babel.init_app(app, locale_selector=get_locale)
    compress.init_app(app)

    with app.app_context() as context:
        from atlas.atlasRoutes import main as main_blueprint
        from atlas.atlasAPI import api

        if app.config["MULTILINGUAL"]:
            # AVEC lang_code
            app.register_blueprint(main_blueprint, url_prefix="/<lang_code>")
            app.register_blueprint(api, url_prefix="/<lang_code>/api")
            # SANS lang_code (langue par défaut)
            app.register_blueprint(
                main_blueprint,
                name="main_no_lang",
            )
            app.register_blueprint(api, name="api_no_lang", url_prefix="/api")
        else:
            # Mode monolingue simple
            app.register_blueprint(main_blueprint)
            app.register_blueprint(api, url_prefix="/api")

        multilingual_utils(app)

        app.wsgi_app = ProxyFix(app.wsgi_app, x_host=1)

        app.wsgi_app = SharedDataMiddleware(
            app.wsgi_app, {app.static_url_path: f"{atlas_static_folder}/custom"}
        )

        if app.config["APPLICATION_ROOT"] != "/":
            app.wsgi_app = DispatcherMiddleware(
                Response("Not Found", status=404),
                {app.config["APPLICATION_ROOT"].rstrip("/"): app.wsgi_app},
            )

        @app.context_processor
        def inject_context():
            configuration = copy.copy(public_config)
            # config overrides are used in tests
            if config_overrides:
                configuration.update(config_overrides)
            now = datetime.now()
            return dict(
                configuration=configuration,
                translations=get_tranlated_labels(),
                now=now,
                timedelta=timedelta,
                page_name=request.endpoint.split(".")[1],
                current_language=get_locale(),
                current_url_prefix=get_current_url_prefix(),
            )

        @app.template_filter("pretty")
        def pretty(val):
            return "{:,}".format(val).replace(",", " ")

    return app
