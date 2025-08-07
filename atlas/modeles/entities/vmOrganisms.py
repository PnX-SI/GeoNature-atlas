# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()
metadata = MetaData()


class VmOrganisms(Base):
    __tablename__ = "vm_cor_taxon_organism"
    __table_args__ = {"schema": "atlas"}
    nb_observations = Column("nb_observations", Integer)
    id_organism = Column("id_organism", Integer, primary_key=True, unique=True)
    nom_organism = Column("nom_organism", String(500))
    adresse_organism = Column("adresse_organism", String(128))
    cp_organism = Column("cp_organism", String(5))
    ville_organism = Column("ville_organism", String(100))
    tel_organism = Column("tel_organism", String(14))
    email_organism = Column("email_organism", String(100))
    url_organism = Column("url_organism", String(255))
    url_logo = Column("url_logo", String(255))
    cd_ref = Column("cd_ref", Integer)
