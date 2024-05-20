# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, Integer, MetaData, Table, Text
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class TMaillesTerritoire(Base):
    __table__ = Table(
        "t_mailles_territoire",
        metadata,
        Column("id_maille", Integer, primary_key=True, unique=True),
        Column("the_geom", Geometry()),
        Column("geojson_maille", Text),
        schema="atlas",
        autoload=True,
        autoload_with=db.engine,
    )
