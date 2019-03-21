from marshmallow import Schema, fields, validates_schema, ValidationError
from marshmallow.validate import OneOf


MAP_1 = {
    "name": "OpenStreetMap",
    "layer": "//{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
    "attribution": "&copy OpenStreetMap",
}
MAP_2 = {
    "name": "GoogleSatellite",
    "layer": "//{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
    "subdomains": ["mt0", "mt1", "mt2", "mt3"],
    "attribution": "© GoogleMap",
}


class MapConfig(Schema):
    LAT_LONG = fields.List(fields.Float(), missing=[44.7952, 6.2287])
    FIRST_MAP = fields.Dict(missing=MAP_1)
    SECOND_MAP = fields.Dict(missing=MAP_2)
    ZOOM = fields.Integer(missing=10)
    STEP = fields.Integer(missing=1)
    BORDERS_COLOR = fields.String(missing="#000000")
    BORDERS_WEIGHT = fields.Integer(missing=3)
    AFFICHAGE_MAILLE = fields.Boolean(missing=False)
    ZOOM_LEVEL_POINT = fields.Integer(missing=11)
    LIMIT_CLUSTER_POINT = fields.Integer(missing=1000)
    NB_DAY_LAST_OBS = fields.String(missing="7 day")
    NB_LAST_OBS = fields.Integer(missing=100)
    TEXT_LAST_OBS = fields.String(
        missing="Les observations des agents ces 7 derniers jours |"
    )


class AtlasConfig(Schema):
    database_connection = fields.String(
        required=True,
        validate=Regexp(
            "^postgresql:\/\/.*:.*@[^:]+:\w+\/\w+$",
            0,
            """Database uri is invalid ex:
             postgresql://monuser:monpass@server:port/db_name""",
        ),
    )
    modeDebug = fields.Boolean(missing=False)
    STRUCTURE = fields.String(missing="Nom de la structure")
    NOM_APPLICATION = fields.String(missing="Nom de l'application")
    URL_APPLICATION = fields.String(missing="")
    ID_GOOGLE_ANALYTICS = fields.String(missing="UA-xxxxxxx-xx")
    GLOSSAIRE = fields.Boolean(missing=False)
    IGNAPIKEY = fields.String(missing="")

