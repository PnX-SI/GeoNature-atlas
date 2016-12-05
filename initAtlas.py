import os
import sys
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy

APP_DIR = os.path.abspath(os.path.dirname(__file__))

from main.configuration import config
from sqlalchemy import create_engine, MetaData, Table

from flask.ext.compress import Compress

db = SQLAlchemy()
compress = Compress()

#renvoie une instance de app l appli Flask
def create_app():
    app = Flask(__name__, template_folder=APP_DIR)
    app.debug = config.modeDebug


    from main.atlasRoutes import main as main_blueprint

    app.register_blueprint(main_blueprint)

    from main.atlasAPI import api
    app.register_blueprint(api, url_prefix='/api')


    compress.init_app(app)

    return app

app = create_app()