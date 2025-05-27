# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmOrganisms(Base):
    __tablename__ = "vm_cor_taxon_organism"
    __table_args__ = {'schema' : 'atlas'}
    
    nb_observations = Column(Integer)
    id_organism = Column(Integer, primary_key=True, unique=True)
    nom_organism = Column(String(500))
    adresse_organism = Column(String(128))
    cp_organism = Column(String(5))
    ville_organism = Column(String(100))
    tel_organism = Column(String(14))
    email_organism = Column(String(100))
    url_organism = Column(String(255))
    url_logo = Column(String(255))
    cd_ref = Column(Integer)