# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, Date, Integer, String, Table, Text, ARRAY
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class VmObservations(Base):
    __tablename__ = "vm_observations"
    __table_args__ = {"schema": "atlas"}
    id_observation = Column("id_observation", Integer, primary_key=True, unique=True)
    dateobs = Column("dateobs", Date, index=True)
    observateurs = Column("observateurs", String(255))
    altitude_retenue = Column("altitude_retenue", Integer, index=True)
    cd_ref = Column("cd_ref", Integer, index=True)
    the_geom_point = Column("the_geom_point", Geometry(geometry_type="POINT", srid=4326))
    geojson_point = Column("geojson_point", Text)
    cd_sensitivity = Column("cd_sensitivity", String(5))
    id_dataset = Column("id_dataset", Integer)
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
    __table_args__ = {"schema": "atlas"}
    cd_ref = Column("cd_ref", Integer, primary_key=True, index=True)
    annee = Column("annee", String(1000), primary_key=True, index=True)
    id_maille = Column("id_maille", Integer, primary_key=True, index=True)
    nbr = Column("nbr", Integer)
    type_code = Column("type_code", String(10))
    id_observations = Column("id_observations", ARRAY(Integer))
