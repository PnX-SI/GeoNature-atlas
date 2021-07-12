# coding: utf-8
from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    Integer,
    MetaData,
    String,
    Table,
    Text,
)
from geoalchemy2.types import Geometry
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.orm import mapper
from sqlalchemy.ext.declarative import declarative_base
from ...utils import engine


metadata = MetaData()
Base = declarative_base()


class VmObservations(Base):
    __table__ = Table(
        "vm_observations",
        metadata,
        Column("id_observation", Integer, primary_key=True, unique=True),
        Column("insee", String(5), index=True),
        Column("dateobs", Date, index=True),
        Column("observateurs", String(255)),
        Column("altitude_retenue", Integer, index=True),
        Column("cd_ref", Integer, index=True),
        Column("geojson_point", Text),
        schema="atlas",
        autoload=True,
        autoload_with=engine,
    )


class VmObservationsMailles(Base):
    """
    Table des observations par maille
    """

    __table__ = Table(
        "vm_observations_mailles",
        metadata,
        Column("id_observation", Integer, primary_key=True, unique=True),
        Column("id_maille", Integer),
        Column("id_type", Integer),
        Column("the_geom", Geometry),
        Column("geojson_maille", String(1000)),
        Column("annee", String(1000)),
        schema="atlas",
        autoload=True,
        autoload_with=engine,
    )

