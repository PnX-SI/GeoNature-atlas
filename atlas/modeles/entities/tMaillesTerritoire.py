# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, Integer, MetaData, Table, Text
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class TMaillesTerritoire(Base):
    __tablename__ = "vm_mailles_territoire"
    __table_args__ = {"schema": "atlas"}

    id_maille = Column("id_maille", Integer, primary_key=True, unique=True)
    the_geom = Column("the_geom", Geometry())
    geojson_maille = Column("geojson_maille", Text)
