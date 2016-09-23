# coding: utf-8
from sqlalchemy import Boolean, Column, Date, DateTime, Integer, MetaData, String, Table, Text
from geoalchemy2.types import Geometry
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.orm import mapper
from sqlalchemy.ext.declarative import declarative_base
from ...utils import engine



metadata = MetaData()
Base = declarative_base()

class VmObservations(Base):
    __table__ = Table(
    'vm_observations', metadata,
    Column('id_observation', Integer, primary_key=True, unique=True),
    Column('id_source', Integer),
    Column('id_fiche_source', String(50)),
    Column('code_fiche_source', String(50)),
    Column('id_protocole', Integer),
    Column('id_precision', Integer),
    Column('insee', String(5), index=True),
    Column('dateobs', Date, index=True),
    Column('observateurs', String(255)),
    Column('determinateur', String(255)),
    Column('altitude_retenue', Integer, index=True),
    Column('remarques', Text),
    Column('date_insert', DateTime),
    Column('date_update', DateTime),
    Column('derniere_action', String(1)),
    Column('the_geom_point', Geometry, index=True),
    Column('id_lot', Integer),
    Column('id_critere_synthese', Integer),
    Column('effectif_total', Integer),
    Column('cd_ref', Integer, index=True),
    Column('geojson_point', Text),
    schema='atlas', autoload=True, autoload_with=engine
)




