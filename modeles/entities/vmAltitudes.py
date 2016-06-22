# coding: utf-8
from sqlalchemy import BigInteger, Column, Date, DateTime, Integer, MetaData, String, Table, Text
from geoalchemy2.types import Geometry
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.orm import mapper
from sqlalchemy.ext.declarative import declarative_base
from atlas.manage import engine
from atlas import BASE_DIR
import sys
sys.path.insert(0, BASE_DIR)


metadata = MetaData()
Base = declarative_base()

class VmAltitudes(Base):
    __table__ = Table(
    'vm_altitudes', metadata,
    Column('cd_ref', Integer, primary_key=True, unique=True),
    Column('_0_500', Integer),
    Column('_500_1000', Integer),
    Column('_1000_1500', Integer),
    Column('_1500_2000', Integer),
    Column('_2000_2500', Integer),
    Column('_2500_3000', Integer),
    Column('_3000_3500', Integer),
    Column('_3500_4000', Integer),
    Column('_4000_4103', Integer),
    schema='atlas', autoload=True, autoload_with=engine
)

