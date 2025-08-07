# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmTaxref(Base):
    __tablename__ = "vm_taxref"
    __table_args__ = {"schema": "atlas"}
    cd_nom = Column("cd_nom", Integer, primary_key=True, unique=True)
    cd_ref = Column("cd_ref", Integer)
    regne = Column("regne", String(20))
    phylum = Column("phylum", String(50))
    classe = Column("classe", String(50))
    ordre = Column("ordre", String(50))
    id_rang = Column("id_rang", String(10))
    famille = Column("famille", String(50))
    cd_taxsup = Column("cd_taxsup", Integer)
    lb_nom = Column("lb_nom", String(100))
    lb_auteur = Column("lb_auteur", String(250))
    nom_complet = Column("nom_complet", String(255))
    nom_valide = Column("nom_valide", String(255))
    nom_vern = Column("nom_vern", String(1000))
    nom_vern_eng = Column("nom_vern_eng", String(500))
    group1_inpn = Column("group1_inpn", String(50))
    group2_inpn = Column("group2_inpn", String(50))
    nom_complet_html = Column("nom_complet_html", String(500))
