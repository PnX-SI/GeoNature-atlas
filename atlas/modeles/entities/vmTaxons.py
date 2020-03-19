# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

Base = declarative_base()
metadata = MetaData()


class VmTaxons(Base):
    __table__ = Table(
        'vm_taxons', metadata,
        Column('cd_ref', Integer, primary_key=True, unique=True),
        Column('regne', String(20)),
        Column('phylum', String(50)),
        Column('classe', String(50)),
        Column('ordre', String(50)),
        Column('famille', String(50)),
        Column('cd_taxsup', Integer),
        Column('lb_nom', String(100)),
        Column('lb_auteur', String(250)),
        Column('nom_complet', String(255)),
        Column('nom_valide', String(255)),
        Column('nom_vern', String(1000)),
        Column('nom_vern_eng', String(500)),
        Column('group1_inpn', String(50)),
        Column('group2_inpn', String(50)),
        Column('nom_complet_html', String(500)),
        # Column('nom_habitat', String(50)),
        # Column('nom_rang', String(20)),
        # Column('nom_statut', String(50)),
        Column('patrimonial', String(255)),
        Column('protection_stricte', String(255)),
        Column('yearmin', Float(53)),
        Column('yearmax', Float(53)),
        schema='atlas', autoload=True, autoload_with=engine
    )
