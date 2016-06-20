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
    Column('altinf500', BigInteger),
    Column('alt500_1000', BigInteger),
    Column('alt1000_1500', BigInteger),
    Column('alt1500_2000', BigInteger),
    Column('alt2000_2500', BigInteger),
    Column('alt2500_3000', BigInteger),
    Column('alt3000_3500', BigInteger),
    Column('alt3500_4000', BigInteger),
    Column('alt_sup4000', BigInteger),
    schema='atlas', autoload=True, autoload_with=engine
)


