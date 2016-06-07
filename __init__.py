import os
import sys
from flask import Flask, render_template
from flask.ext.sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap
from config import config, database_connection
from flask.ext.sqlalchemy import SQLAlchemy


appDir = os.path.abspath(os.path.dirname(__file__))
baseDir = os.path.abspath(os.path.join(appDir, os.pardir))
templateDir = appDir+'/templates'


bootstrap = Bootstrap()
db = SQLAlchemy()

#renvoie une instance de app l appli Flask et d'engine: la connection a la base de donnee
def create_app(config_name):
    app = Flask(__name__, template_folder=templateDir)

    from sqlalchemy import create_engine
    engine = create_engine(database_connection, client_encoding='utf8', echo = False)
    bootstrap.init_app(app)
    

    from main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return dict(app=app, engine=engine)
