# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, MetaData, String, Table, Integer, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmBibAreasTypes(Base):
    __tablename__ = "vm_bib_areas_types"
    __table_args__ = {"schema": "atlas"}
    id_type = Column("id_type", Integer(), primary_key=True, unique=True)
    type_code = Column("type_code", String(50))
    type_name = Column("type_name", String(250))
    type_desc = (Column("type_desc", Text()),)


class VmAreas(Base):
    __tablename__ = "vm_l_areas"
    __table_args__ = {"schema": "atlas"}
    id_area = (Column("id_area", Integer(), primary_key=True, unique=True),)
    area_code = (Column("area_code", String(50)),)
    area_name = (Column("area_name", String(50)),)
    id_type = (Column("id_type", Integer(), ForeignKey("atlas.vm_bib_areas_types.id_type")),)
    the_geom = (Column("the_geom", Geometry("MULTIPOLYGON", 4326), index=True),)
    area_geojson = (Column("area_geojson", Text()),)


class VmCorAreaObservation(Base):
    __tablename__ = "vm_cor_area_observation"
    __table_args__ = {"schema": "atlas"}
    id_observation = (Column("id_observation", Integer(), primary_key=True),)
    id_area = (Column("id_area", Integer(), primary_key=True),)
    # observation = relationship("VmObservations", foreign_keys=[__table__.c.id_observation])
    # area = relationship("VmAreas", foreign_keys=[__table__.c.id_area])
