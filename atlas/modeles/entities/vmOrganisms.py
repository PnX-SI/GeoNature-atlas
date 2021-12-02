# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

Base = declarative_base()
metadata = MetaData()

class VmOrganisms(Base):
    __table__=Table(
        'vm_cor_taxon_organism',
        metadata,
        Column('nb_observations', Integer),
        Column('id_organism', Integer, primary_key=True, unique =True),
        Column ('nom_organism',String(500)),
        Column ('adresse_organism', String (128)),
        Column ('cp_organism', String(5)),
        Column ('ville_organism', String(100)),
        Column ('tel_organism',String(14)),
        Column ('email_organism', String(100)),
        Column ('url_organism', String(255)),
        Column ('url_logo', String(255)),
        Column('cd_ref',Integer),
        schema="atlas",
        autoload=True,
        autoload_with=engine
    ) 