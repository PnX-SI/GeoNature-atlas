# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, String, Text, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmTaxref(Base):
    __tablename__ = "vm_taxref"
    __table_args__ = {"schema" : "atlas"}

    cd_nom = Column(Integer, primary_key = True)
    id_statut = Column(String(1))
    id_habitat = Column(Integer)
    id_rang = Column(String(4))
    regne = Column(String(20))
    phylum = Column(String(50))
    classe = Column(String(50))
    ordre = Column(String(50))
    famille = Column(String(50))
    sous_famille = Column(String(50))
    tribu = Column(String(50))
    cd_taxsup = Column(Integer)
    cd_sup = Column(Integer)
    cd_ref = Column(Integer, index=True)
    lb_nom = Column(String(100), index=True)
    lb_auteur = Column(String(250))
    nom_complet = Column(String(255), index=True)
    nom_complet_html = Column(String(500))
    nom_valide = Column(String(255) , index=True)
    nom_vern = Column(String(1000))
    nom_vern_eng = Column(String(500))
    group1_inpn = Column(String(50))
    group2_inpn = Column(String(50))
    url = Column(Text)
    group3_inpn = Column(String(250))

    
