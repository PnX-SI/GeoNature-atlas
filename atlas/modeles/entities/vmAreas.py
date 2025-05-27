# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, MetaData, String, Table, Integer, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from atlas.env import db

Base = declarative_base()


class VmBibAreasTypes(Base):
    __tablename__ = "vm_bib_areas_types"
    __table_args__ = {"schema" : "atlas"} 

    id_type = Column(Integer, primary_key=True)
    type_code = Column(String(50))
    type_name = Column(String(250))
    type_desc = Column(Text)
    areas = relationship("VmAreas")

class VmAreas(Base):
    __tablename__ = "vm_l_areas"
    __table_args__ = {"schema" : "atlas"}

    id_area = Column(Integer, primary_key=True)
    area_code = Column(String(50))
    area_name = Column(String(50))
    id_type = Column(Integer, ForeignKey("atlas.vm_bib_areas_types.id_type") )
    the_geom = Column(Geometry("MULTIPOLYGON", 4326), index=True)
    area_geojson = Column(Text)
    description =  Column(Text)


    