# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import String, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import relationship
from typing import List


class Base(DeclarativeBase):
    pass

class VmBibAreasTypes(Base):
    __tablename__ = "vm_bib_areas_types"
    __table_args__ = {"schema" : "atlas"} 

    id_type: Mapped[int] = mapped_column(primary_key=True)
    type_code: Mapped[str] = mapped_column(String(50)) 
    type_name: Mapped[str] = mapped_column(String(250))
    type_desc: Mapped[str] = mapped_column(Text)
    areas: Mapped[List["VmAreas"]] = relationship("VmAreas", back_populates="type")

class VmAreas(Base):
    __tablename__ = "vm_l_areas"
    __table_args__ = {"schema" : "atlas"}

    id_area: Mapped[int] = mapped_column(primary_key = True)
    area_code: Mapped[str] = mapped_column(String(50)) 
    area_name: Mapped[str] = mapped_column(String(50)) 
    id_type: Mapped[int] = mapped_column(ForeignKey("atlas.vm_bib_areas_types.id_type"))
    the_geom: Mapped[object] = mapped_column(Geometry("MULTIPOLYGON", 4326), index=True) 
    area_geojson: Mapped[str] = mapped_column(Text)
    description: Mapped[str] = mapped_column(Text)
    type: Mapped["VmBibAreasTypes"] = relationship("VmBibAreasTypes", back_populates="areas")

class VmCorAreas(Base):
    __tablename__ = 'vm_cor_areas'
    __table_args__ = {'schema': 'atlas'}

    id_area: Mapped[int] = mapped_column(primary_key = True) 
    id_area_group: Mapped[int] = mapped_column(primary_key = True) 

class VmCorAreaSynthese(Base):
    __tablename__ = 'vm_cor_area_synthese'
    __table_args__ = {'schema': 'atlas'}

    id_synthese: Mapped[int] = mapped_column(primary_key = True) 
    id_area: Mapped[int] = mapped_column(primary_key = True) 
    id_type: Mapped[int] = mapped_column(primary_key = True) 
    type_code: Mapped[str] = mapped_column(String(25))

class VmAreaStatTaxonomyGroup(Base):
    __tablename__ = "vm_area_stats_by_taxonomy_group"
    __table_args__ = {"schema" : "atlas"}

    id_area: Mapped[int] = mapped_column(primary_key =  True)
    group2_inpn: Mapped[str] = mapped_column(String(50), primary_key = True)

    nb_obs: Mapped[int] = mapped_column()
    nb_species: Mapped[int] = mapped_column()
    nb_patrominal: Mapped[int] = mapped_column()
    nb_taxon_protege: Mapped[int] = mapped_column()
    nb_species_in_teritory: Mapped[int] = mapped_column()

class VmAreaStats(Base):
    __tablename__ = "vm_area_stats"
    __table_args__ = {"schema" : "atlas"}

    id_area: Mapped[int] = mapped_column(primary_key = True) 
    nb_obs: Mapped[int] = mapped_column()
    nb_species: Mapped[int] = mapped_column()
    nb_observers: Mapped[int] = mapped_column()
    nb_organism: Mapped[int] = mapped_column()
    yearmin: Mapped[int] = mapped_column()
    yearmax: Mapped[int] = mapped_column()
    nb_taxon_patrimonial: Mapped[int] = mapped_column()
    nb_taxon_protege: Mapped[int] = mapped_column()
    description: Mapped[str] = mapped_column(Text)
    
    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class VmAreaStatsOrganism(Base):
    __tablename__ = "vm_area_stats_by_organism"
    __table_args__ = {"schema" : "atlas"}

    id_area: Mapped[int] = mapped_column(primary_key = True)
    nom_organism: Mapped[str] = mapped_column(String(500), primary_key = True)
    
    nb_species: Mapped[int] = mapped_column() 
    nb_obs: Mapped[int] = mapped_column() 

