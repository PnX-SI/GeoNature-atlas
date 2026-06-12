"""
Utils pour lire le fichier de conf et le valider selon le schéma Marshmallow
"""

import copy
from importlib.machinery import SourceFileLoader
from marshmallow import EXCLUDE
from atlas.env import atlas_config_file_path
from atlas.configuration.config_schema import AtlasConfig, SecretSchemaConf


import importlib.util
from pathlib import Path


def load_python_config(path) -> dict:
    path = Path(path)

    spec = importlib.util.spec_from_file_location("user_config", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Convertit le module en dict
    return read_config_file(module)


def get_config_module(atlas_config_file_path):
    # imports the module from the given path
    atlas_config = SourceFileLoader("config", atlas_config_file_path).load_module()
    return atlas_config


def read_config_file(config_module):
    return {var: getattr(config_module, var) for var in remove_reserved_word(config_module)}


def remove_reserved_word(config_module):
    return [var for var in dir(config_module) if not var.startswith("__")]


def valid_config_from_dict(config_dict, config_schema):
    return config_schema(unknown=EXCLUDE).load(config_dict)


config = load_python_config(atlas_config_file_path)

public_config = valid_config_from_dict(config, AtlasConfig)
secret_config = valid_config_from_dict(config, SecretSchemaConf)

config.update(public_config)
config.update(secret_config)
