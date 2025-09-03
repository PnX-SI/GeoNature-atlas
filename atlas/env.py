import os
from pathlib import Path
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import DeclarativeBase

from flask_caching import Cache
from flask_babel import Babel

class Base(DeclarativeBase):
  pass

babel = Babel()

cache = Cache(config={"CACHE_TYPE": "SimpleCache"})

db = SQLAlchemy(model_class=Base)

default_atlas_config_file_path = Path(__file__).parent / "configuration/config.py"
default_atlas_static_folder = Path(__file__).parent / "static"
default_atlas_template_folder = Path(__file__).parent


atlas_config_file_path = os.environ.get("ATLAS_SETTINGS", default_atlas_config_file_path)
atlas_static_folder = os.environ.get("ATLAS_STATIC_FOLDER", default_atlas_static_folder)
atlas_template_folder = os.environ.get("ATLAS_TEMPLATE_FOLDER", default_atlas_template_folder)