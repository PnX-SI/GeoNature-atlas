# -*- coding:utf-8 -*-

from sqlalchemy import Column, Integer, MetaData, String, Table, Float, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

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
    attributs = relationship("VmCorTaxonAttribut", back_populates="taxon")
    organisms = relationship("VmCorTaxonOrganism", back_populates="taxon")

class VmCorTaxonAttribut(Base):
    __tablename__ = "vm_cor_taxon_attribut"
    __table_args__ = {"schema" : "atlas"}

    id_attribut = Column(Integer, primary_key=True)
    cd_ref = Column(Integer, ForeignKey("atlas.vm_taxons.cd_ref"), primary_key=True)
    valeur_attribut = Column(Text)
    taxon = relationship("VmTaxons", back_populates="attributs")

class VmCorTaxonOrganism(Base):
    __tablename__ = "vm_cor_taxon_organism"
    __table_args__ = {"schema" : "atlas"}

    cd_ref = Column(Integer, ForeignKey("atlas.vm_taxons.cd_ref"), primary_key=True)
    id_organism = Column(Integer, primary_key=True)

    nb_observations = Column(Integer)
    nom_organism = Column(String(500))
    adress_organism = Column(String(128))
    cp_organism = Column(String(5))
    ville_organism = Column(String(100))
    tel_organism = Column(String(14))
    email_organism = Column(String(100))
    url_organism = Column(String(255))
    url_logo = Column(String(255))
    taxon = relationship("VmTaxons", back_populates="organisms")

class VmTaxonsMostView(Base):
    __tablename__ = "vm_taxons_plus_observes"
    __table_args__ = {"schema" : "atlas"}

    cd_ref = Column(Integer, primary_key = True)
    nb_obs = Column(Integer)
    lb_nom = Column(String(250))
    group2_inpn = Column(String(50))
    nom_vern = Column(String(1000))
    id_media = Column(Integer)
    url = Column(String(255))
    chemin = Column(String(255))
    id_type = Column(Integer)

