import os
import sys
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy

from werkzeug.serving import run_simple

from atlas.configuration import config
from sqlalchemy import create_engine, MetaData, Table

from flask_compress import Compress

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
    # renvoie une instance de app l appli Flask
    from atlas.configuration import config
    from atlas.configuration.config_parser import read_and_validate_conf
    from atlas.configuration.config_schema import AtlasConfig

    config = read_and_validate_conf(config, AtlasConfig)
    app = Flask(__name__, template_folder=APP_DIR)
    # push the config in app config at 'PUBLIC' key
    app.config.update({"PUBLIC": config})

    app.debug = config["modeDebug"]
    with app.app_context() as context:
        from atlas.atlasRoutes import main as main_blueprint

        app.register_blueprint(main_blueprint)

        from atlas.atlasAPI import api

        app.register_blueprint(api, url_prefix="/api")

        compress.init_app(app)

        app.wsgi_app = ReverseProxied(
            app.wsgi_app, script_name=config["URL_APPLICATION"]
        )

        @app.context_processor
        def inject_config():
            return dict(configuration=app.config["PUBLIC"])

    return app


app = create_app()


if __name__ == "__main__":
    from flask_script import Manager

    app.debug = True
    app.run(port=8080, debug=True)
    # Manager(app).run()
    # run_simple("localhost", 8080, app, use_reloader=True)
