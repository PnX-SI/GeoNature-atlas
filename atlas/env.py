from atlas.configuration.config_parser import valid_config_from_dict, read_config_file
from atlas.configuration.config_schema import AtlasConfig, SecretSchemaConf

from atlas.configuration import config


config_dict = read_config_file(config)
config = valid_config_from_dict(config_dict, AtlasConfig)
secret_conf = valid_config_from_dict(config_dict, SecretSchemaConf)