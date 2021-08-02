# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

Base = declarative_base()
metadata = MetaData()

class VmOrganismes(Base):
    __table__=Table(
        'vm_organismes',
        metadata,
        Column('nb_observations', Integer),
        Column('id_organisme', Integer, primary_key=True, unique =True),
        Column ('nom_organisme',String(500)),
        Column ('adresse_organisme', String (128)),
        Column ('cp_organisme', String(5)),
        Column ('ville_organisme', String(100)),
        Column ('tel_organisme',String(14)),
        Column ('email_organisme', String(100)),
        Column ('url_organisme', String(255)),
        Column ('url_logo', String(255)),
        Column('cd_ref',Integer,
        schema="atlas",
        autoload=True,
        autoload_with=engine,
    )