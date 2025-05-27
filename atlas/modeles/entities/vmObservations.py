# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, Date, Integer, MetaData, String, Table, Text, ARRAY
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmObservations(Base):
    __tablename__ = "vm_observations"
    __table_args__ = {"schema":"atlas"}

    id_observation = Column(Integer, primary_key=True)
    dateobs = Column(Date, index=True)
    observateurs = Column(String(255))
    altitude_retenue = Column(Integer, index=True)
    cd_ref = Column(Integer, index=True)
    the_geom_point = Column(Geometry(geometry_type="POINT", srid=4326))
    geojson_point = Column(Text)
    cd_sensitivity = Column(String(255))

    def as_dict(self):
        return {
            "dateobs": str(self.dateobs),
            "year": self.dateobs.year if self.dateobs else None,
            "id_observation": self.id_observation,
            "observateurs": self.observateurs,
            "altitude_retenue": self.altitude_retenue,
            "cd_ref": self.cd_ref,
            "cd_sensitivity": self.cd_sensitivity,
        }
    
class VmObservationsMailles(Base):
    """
    Table des observations par maille
    """
    __tablename__ = "vm_observations_mailles"
    __table_args__ = {"schema" : "atlas"}

    cd_ref = Column(Integer, primary_key=True, index=True)
    annee = Column(String(1000), primary_key=True, index=True)
    id_maille = Column(Integer, primary_key=True, index=True)
    nbr = Column(Integer)
    id_observations = Column(ARRAY(Integer))
    type_code = Column(String(25))
