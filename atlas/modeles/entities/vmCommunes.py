# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Column, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

metadata = MetaData()
Base = declarative_base()


class VmCommunes(Base):
    __table__ = Table(
        'vm_communes', metadata,
        Column('insee', String(5), primary_key=True, unique=True),
        Column('commune_maj', String(50)),
        # Column('commune_min', String(50)),
        Column('the_geom', Geometry(u'MULTIPOLYGON', 2154), index=True),
        schema='atlas', autoload=True, autoload_with=engine
    )
