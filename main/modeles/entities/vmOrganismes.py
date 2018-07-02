# coding: utf-8
#from sqlalchemy import Column, Integer, MetaData, String, Table
#from geoalchemy2.types import Geometry
#from sqlalchemy.sql.sqltypes import NullType
#from sqlalchemy.orm import mapper
#from sqlalchemy.ext.declarative import declarative_base
#from ...utils import engine

#metadata = MetaData()
#Base = declarative_base()

class VmMois(Base):
    __table__ = Table(
    'vm_organismes', metadata,
    Column('id_organisme', Integer, primary_key=True, unique=True),
    Column('nom_organisme', String(250)),
    schema='atlas', autoload=True, autoload_with=engine
)


