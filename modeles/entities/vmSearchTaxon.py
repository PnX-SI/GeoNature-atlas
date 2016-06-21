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

class VmSearchTaxon(Base):
    __table__ = Table(
    'vm_search_taxon', metadata,
    Column('cd_ref', Integer, primary_key=True, unique=True),
    Column('nom_search', Integer),
    schema='atlas', autoload=True, autoload_with=engine
)


