# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmTaxons(Base):
    __tablename__ = "vm_taxons"
    __table_args__ = {"schema" : "atlas"}

    cd_ref = Column(Integer, primary_key=True)
    regne = Column(String(20))
    phylum = Column(String(50))
    classe = Column(String(50)) 
    ordre = Column(String(50))
    famille = Column(String(50))
    cd_taxsup = Column(Integer)
    lb_nom = Column(String(100))
    lb_auteur = Column(String(250))
    nom_complet = Column(String(255))
    nom_valide = Column(String(255))
    nom_vern = Column(String(1000))
    nom_vern_eng = Column(String(500))
    group1_inpn = Column(String(50))
    group2_inpn = Column(String(50))
    nom_complet_html = Column(String(500))
    id_rang = Column(String(10)) 
    patrimonial = Column(String(255))
    protection_stricte = Column(String(255))
    yearmin = Column(Float(53))
    yearmax = Column(Float(53))
    nb_obs = Column(Integer)
