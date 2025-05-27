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

class VmCorAreas(Base):
    __tablename__ = 'vm_cor_areas'
    __table_args__ = {'schema': 'atlas'}

    id_area = Column(Integer, primary_key=True)
    id_area_group = Column(Integer, primary_key=True)

class VmCorAreaSynthese(Base):
    __tablename__ = 'vm_cor_area_synthese'
    __table_args__ = {'schema': 'atlas'}

    id_synthese =Column(Integer, primary_key = True)
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer, primary_key=True)
    type_code = Column(String(25))

class VmAreaStatTaxonomyGroup(Base):
    __tablename__ = "vm_area_stats_by_taxonomy_group"
    __table_args__ = {"schema" : "atlas"}

    id_area = Column(Integer, primary_key=True)
    group2_inpn = Column(String(50), primary_key=True)

    nb_obs = Column(Integer)
    nb_species = Column(Integer)
    nb_patrominal = Column(Integer)
    nb_taxon_protege = Column(Integer)
    nb_species_in_teritory = Column(Integer)

class VmAreaStats(Base):
    __tablename__ = "vm_area_stats"
    __table_args__ = {"schema" : "atlas"}

    id_area = Column(Integer, primary_key =  True)
    nb_obs = Column(Integer)
    nb_species = Column(Integer)
    nb_observers = Column(Integer)
    nb_organism = Column(Integer)
    yearmin = Column(Integer)
    yearmax = Column(Integer)
    nb_taxon_patrimonial = Column(Integer)
    nb_taxon_protege = Column(Integer)
    description = Column(Text)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}


