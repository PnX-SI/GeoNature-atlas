#!/usr/bin/python
# -*- coding: utf-8 -*-

from geoalchemy2.types import Geometry
from sqlalchemy import (
    Column,
    Integer,
    Text,
)
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata


class TGrid(Base):
    __tablename__ = "t_mailles_territoire"
    __table_args__ = {"schema": "atlas"}

    id_maille = Column(Integer, primary_key=True)
    the_geom = Column(Geometry(geometry_type="MULTIPOLYGON", srid=4326))
    geosjon_maille = Column(Text)
