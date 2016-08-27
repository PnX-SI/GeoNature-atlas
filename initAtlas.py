import os
import sys
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap

APP_DIR = os.path.abspath(os.path.dirname(__file__))
TEMPLATE_DIR = APP_DIR+'/templates'

from main.configuration import config
from sqlalchemy import create_engine, MetaData, Table

bootstrap = Bootstrap()
db = SQLAlchemy()

#renvoie une instance de app l appli Flask et d'engine: la connection a la base de donnee
def create_app(config_name):
    app = Flask(__name__, template_folder=TEMPLATE_DIR)
    app.debug = True

    from main import main as main_blueprint
    app.register_blueprint(main_blueprint)
    bootstrap.init_app(app)

    return dict(app=app)



globalApp = create_app('development')
app = globalApp['app']


