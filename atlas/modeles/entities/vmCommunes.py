# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmCommunes(Base):
    __tablename__ = "vm_communes"
    __table_args__ = {"schema": "atlas"}
    insee = Column("insee", String(5), primary_key=True, unique=True)
    commune_maj = Column("commune_maj", String(50))
    the_geom = Column("the_geom", Geometry("MULTIPOLYGON"), index=True)
