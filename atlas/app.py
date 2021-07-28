import os

from flask import Flask, request, session, redirect, url_for
from flask_compress import Compress
from flask_sqlalchemy import SQLAlchemy
from flask_babel import Babel, format_date, gettext, ngettext, get_locale

from atlas.configuration import config
from atlas.configuration.config_parser import read_and_validate_conf
from atlas.configuration.config_schema import AtlasConfig, SecretSchemaConf
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
    # validation de la configuration
    # configuration publique
    valid_config = read_and_validate_conf(config, AtlasConfig)
    app = Flask(__name__, template_folder=APP_DIR)
    # push the config in app config at 'PUBLIC' key
    app.config.update(valid_config)
    babel = Babel(app)

    #Getting browser language
    @babel.localeselector
    def get_locale():
        # if the user has set up the language manually it will be stored in the session,
        # so we use the locale from the user settings
        try:
            language = session['language']
        except KeyError:
            language = None
        if request.args.get('language'):
            session['language'] = request.args.get('language')
        return session.get('language', request.accept_languages.best_match(config.LANGUAGES.keys()))
    

    app.debug = valid_config["modeDebug"]
    with app.app_context() as context:
        from atlas.atlasRoutes import main as main_blueprint

        app.register_blueprint(main_blueprint)

        from atlas.atlasAPI import api

        from atlas.atlasRoutes import index_bp
        app.register_blueprint(index_bp)

        app.register_blueprint(api, url_prefix="/api")
        compress.init_app(app)

        app.wsgi_app = ReverseProxied(
            app.wsgi_app, script_name=valid_config["URL_APPLICATION"]
        )

        @app.context_processor
        def inject_config():
            return dict(configuration=valid_config)

        @app.template_filter("pretty")
        def pretty(val):
            return format_number(val)


        @app.context_processor
        def inject_conf_var():
            return dict(
                    AVAILABLE_LANGUAGES=config.LANGUAGES,
                    CURRENT_LANGUAGE=session.get('language',request.accept_languages.best_match(config.LANGUAGES.keys()))
                    )

    return app


if __name__ == "__main__":
    # validation de la configuration secrète
    app = create_app()
    secret_conf = read_and_validate_conf(config, SecretSchemaConf)
    app.run(
        host="0.0.0.0", port=secret_conf["GUNICORN_PORT"], debug=app.config["modeDebug"]
    )
