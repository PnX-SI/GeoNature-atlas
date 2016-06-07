#! /usr/bin/python
# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.orm import mapper
from sqlalchemy.ext.declarative import declarative_base
from atlas.manage import engine
from atlas import baseDir
import sys

sys.path.insert(0, baseDir)

Base = declarative_base()
metadata = MetaData()

class TaxrefBibtaxons(Base):
    __table__ = Table(
    'taxref_bib_taxons', metadata,
    Column('id_taxon', Integer, primary_key=True ),
    Column('cd_nom', Integer),
    Column('nom_latin', String(100)),
    Column('nom_francais', String(255)),
    Column('auteur', String(200)),
    Column('regne', String(20)),
    Column('group1_inpn', String(255)),
    Column('group2_inpn', String(255)),
    schema='taxonomie', autoload=True, autoload_with=engine
)

# Session = sessionmaker(bind=engine)
# session = Session()
# res = session.query(TaxrefBibtaxons.group1_inpn).all()
# print res