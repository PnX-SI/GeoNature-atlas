import os
import sys
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap

APP_DIR = os.path.abspath(os.path.dirname(__file__))
BASE_DIR = os.path.abspath(os.path.join(APP_DIR, os.pardir))
TEMPLATE_DIR = APP_DIR+'/templates'
CONFIG_DIR = APP_DIR+'/config'

sys.path.insert(0, CONFIG_DIR)
from config import config, database_connection

bootstrap = Bootstrap()
db = SQLAlchemy()

#renvoie une instance de app l appli Flask et d'engine: la connection a la base de donnee
def create_app(config_name):
    app = Flask(__name__, template_folder=TEMPLATE_DIR)
    app.debug = True

    from sqlalchemy import create_engine
    engine = create_engine(database_connection, client_encoding='utf8', echo = False)
    bootstrap.init_app(app)
    
    from main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return dict(app=app, engine=engine)
