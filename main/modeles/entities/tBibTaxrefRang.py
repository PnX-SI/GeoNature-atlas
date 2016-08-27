# coding: utf-8
from sqlalchemy import BigInteger, Boolean, Column, ForeignKey, Integer, String, Table, Text
from geoalchemy2 import Geometry
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from ...utils import engine


Base = declarative_base()
metadata = Base.metadata

class TBibTaxrefRang(Base):
    __table__ = Table(
    'bib_taxref_rangs', metadata,
    Column('id_rang', String(4), nullable=False, primary_key=True),
    Column('nom_rang', String(20), nullable=False),
    Column('tri_rang', Integer),
    schema='atlas'
)
