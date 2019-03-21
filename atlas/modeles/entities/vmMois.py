# coding: utf-8
from sqlalchemy import BigInteger, Column, Date, DateTime, Integer, MetaData, String, Table, Text
from geoalchemy2.types import Geometry
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.orm import mapper
from sqlalchemy.ext.declarative import declarative_base
from ...utils import engine

metadata = MetaData()
Base = declarative_base()

class VmMois(Base):
    __table__ = Table(
    'vm_mois', metadata,
    Column('cd_ref', Integer, primary_key=True, unique=True),
    Column('_01', Integer),
    Column('_02', Integer),
    Column('_03', Integer),
    Column('_04', Integer),
    Column('_05', Integer),
    Column('_06', Integer),
    Column('_07', Integer),
    Column('_08', Integer),
    Column('_09', Integer),
    Column('_10', Integer),
    Column('_11', Integer),
    Column('_12', Integer),
    schema='atlas', autoload=True, autoload_with=engine
)


