import os

from flask import Flask, request, session, redirect, url_for, g
from flask_compress import Compress
from flask_sqlalchemy import SQLAlchemy
from flask_babel import Babel, format_date, gettext, ngettext, get_locale

from atlas.env import config, secret_conf
from atlas.utils import format_number

db = SQLAlchemy()
compress = Compress()

APP_DIR = os.path.abspath(os.path.dirname(__file__))


class ReverseProxied(object):
    def __init__(self, app, script_name=None, scheme=None, server=None):
        self.app = app
        self.script_name = script_name
        self.scheme = scheme
        self.server = server

    def __call__(self, environ, start_response):
        script_name = environ.get("HTTP_X_SCRIPT_NAME", "") or self.script_name
        if script_name:
            environ["SCRIPT_NAME"] = script_name
            path_info = environ["PATH_INFO"]
            if path_info.startswith(script_name):
                environ["PATH_INFO"] = path_info[len(script_name) :]
        scheme = environ.get("HTTP_X_SCHEME", "") or self.scheme
        if scheme:
            environ["wsgi.url_scheme"] = scheme
        server = environ.get("HTTP_X_FORWARDED_SERVER", "") or self.server
        if server:
            environ["HTTP_HOST"] = server
        return self.app(environ, start_response)


def create_app():
    """
    renvoie une instance de l'app Flask
    """
    app = Flask(__name__, template_folder=APP_DIR)
    # push the config in app config at 'PUBLIC' key
    app.config.update(config)
    babel = Babel(app)

    @babel.localeselector
    def get_locale():
        # if MULTILINGUAL, valid language is in g via before_request_hook
        if config["MULTILINGUAL"]:
            return g.lang_code
        return config["DEFAULT_LANGUAGE"]

    app.debug = secret_conf["modeDebug"]
    app.config["SECRET_KEY"] = secret_conf["SECRET_KEY"]
    with app.app_context() as context:
        from atlas.atlasRoutes import main as main_blueprint

        if config["MULTILINGUAL"]:
            app.register_blueprint(main_blueprint, url_prefix="/<lang_code>")
        app.register_blueprint(main_blueprint)

        from atlas.atlasAPI import api

        app.register_blueprint(api, url_prefix="/api")
        compress.init_app(app)

        app.wsgi_app = ReverseProxied(
            app.wsgi_app, script_name=config["URL_APPLICATION"]
        )

        @app.context_processor
        def inject_config():
            return dict(configuration=config)

        @app.template_filter("pretty")
        def pretty(val):
            return format_number(val)

    return app


if __name__ == "__main__":
    # validation de la configuration secrète
    app = create_app()
    app.run(
        host="0.0.0.0",
        port=secret_conf["GUNICORN_PORT"],
        debug=secret_conf["modeDebug"],
    )
