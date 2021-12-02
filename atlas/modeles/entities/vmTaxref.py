# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

metadata = MetaData()
Base = declarative_base()


class VmTaxref(Base):
    __table__ = Table(
        'vm_taxref', metadata,
        Column('cd_nom', Integer, unique=True, primary_key=True),
        Column('id_statut', String(1)),
        Column('id_habitat', Integer),
        Column('id_rang', String(4)),
        Column('regne', String(20)),
        Column('phylum', String(50)),
        Column('classe', String(50)),
        Column('ordre', String(50)),
        Column('famille', String(50)),
        Column('cd_taxsup', Integer),
        Column('cd_ref', Integer, index=True),
        Column('lb_nom', String(100), index=True),
        Column('lb_auteur', String(250)),
        Column('nom_complet', String(255), index=True),
        Column('nom_valide', String(255), index=True),
        Column('nom_vern', String(1000)),
        Column('nom_vern_eng', String(500)),
        Column('group1_inpn', String(50)),
        Column('group2_inpn', String(50)),
        Column('nom_complet_html', String(500)),
        schema='atlas', autoload=True, autoload_with=engine
    )
