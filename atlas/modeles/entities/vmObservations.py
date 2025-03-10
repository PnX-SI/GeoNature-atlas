# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, Date, Integer, MetaData, String, Table, Text, ARRAY
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmObservations(Base):
    __table__ = Table(
        "vm_observations_test",
        metadata,
        Column("id_observation", Integer, primary_key=True, unique=True),
        Column("dateobs", Date, index=True),
        Column("observateurs", String(255)),
        Column("altitude_retenue", Integer, index=True),
        Column("cd_ref", Integer, index=True),
        Column("the_geom_point", Geometry(geometry_type="POINT", srid=4326)),
        Column("geojson_point", Text),
        Column("id_area_blurring", Integer),
        Column("cd_sensitivity"),
        schema="atlas",
        autoload=True,
        autoload_with=db.engine,
    )

    def as_dict(self):
        return {
            "dateobs": str(self.dateobs),
            "year": self.dateobs.year if self.dateobs else None,
            "id_observation": self.id_observation,
            "observateurs": self.observateurs,
            "altitude_retenue": self.altitude_retenue,
            "cd_ref": self.cd_ref,
            "cd_sensitivity": self.cd_ref,
            "id_area_blurring": self.id_area_blurring,
        }


class VmObservationsMailles(Base):
    """
    Table des observations par maille
    """

    __table__ = Table(
        "vm_observations_mailles",
        metadata,
        Column("cd_ref", Integer, primary_key=True, index=True),
        Column("annee", String(1000), primary_key=True, index=True),
        Column("id_maille", Integer, primary_key=True, index=True),
        Column("nbr", Integer),
        Column("id_observations", ARRAY(Integer)),
        schema="atlas",
        autoload=True,
        autoload_with=db.engine,
    )
