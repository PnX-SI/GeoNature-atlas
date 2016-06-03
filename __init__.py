import os
import sys
from flask import Flask, render_template
from flask.ext.sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap
from config import config, database_connection
from flask.ext.sqlalchemy import SQLAlchemy


dirpath = os.path.abspath(os.path.dirname(__file__))
templatePath = dirpath+'/templates'


bootstrap = Bootstrap()
db = SQLAlchemy()


def create_app(config_name):
    app = Flask(__name__, template_folder=templatePath)

    from sqlalchemy import create_engine
    engine = create_engine(database_connection, client_encoding='utf8', echo = False)
    bootstrap.init_app(app)
    #db.init_app(app)

    from main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return dict(app=app, engine=engine)
