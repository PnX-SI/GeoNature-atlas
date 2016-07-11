# coding: utf-8
from sqlalchemy import BigInteger, Boolean, Column, ForeignKey, Integer, String, Table, Text
from geoalchemy2 import Geometry
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from atlas.manage import engine
from atlas import BASE_DIR
import sys
sys.path.insert(0, BASE_DIR)


Base = declarative_base()
metadata = Base.metadata

class TBibTaxrefRang(Base):
    __table__ = Table(
    'temp_bib_taxref_rangs', metadata,
    Column('id_rang', String(4), nullable=False, primary_key=True),
    Column('nom_rang', String(20), nullable=False),
    Column('tri_rang', Integer),
    schema='atlas'
)
