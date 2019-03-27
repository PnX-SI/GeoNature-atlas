"""
Utils pour lire le fichier de conf et le valider selon le schéma Marshmallow 
"""

from pathlib import Path


def read_and_validate_conf(config_module, config_schema):
    conf_dict = {
        var: getattr(config_module, var) for var in remove_reserved_word(config_module)
    }
    configs_py, configerrors = config_schema().load(conf_dict)
    if configerrors:
        raise Exception(
            "Erreur dans le fichier de configuraiton: {}".format(configerrors)
        )
    return configs_py


def remove_reserved_word(config_module):
    return [var for var in dir(config_module) if not var.startswith("__")]


def read_and_validation_from_dict(config_dict, config_schema):
    configs_py, configerrors = config_schema().load(conf_dict)
    if configerrors:
        raise Exception(configerrors)
    return configs_py
