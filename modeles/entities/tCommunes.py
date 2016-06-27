# coding: utf-8
from sqlalchemy import BigInteger, Boolean, Column, ForeignKey, Integer, String
from geoalchemy2 import Geometry
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from atlas.manage import engine
from atlas import BASE_DIR
import sys
sys.path.insert(0, BASE_DIR)


Base = declarative_base()
metadata = Base.metadata


class LCommune(Base):
    __tablename__ = 'l_communes'
    __table_args__ = {u'schema': 'layers'}

    insee = Column(String(5), primary_key=True)
    idbdcarto = Column(BigInteger)
    commune_maj = Column(String(50))
    commune_min = Column(String(50))
    inseedep = Column(String(3))
    nomdep = Column(String(30))
    inseereg = Column(String(2))
    nomreg = Column(String(30))
    inseearr = Column(String(1))
    inseecan = Column(String(2))
    statut = Column(String(20))
    xcom = Column(BigInteger)
    ycom = Column(BigInteger)
    surface = Column(BigInteger)
    epci = Column(String(40))
    coeur_aoa = Column(String(5))
    codenum = Column(Integer)
    pays = Column(String(50))
    id_secteur = Column(ForeignKey(u'layers.l_secteurs.id_secteur', onupdate=u'CASCADE'), index=True)
    saisie = Column(Boolean)
    organisme = Column(Boolean)
    id_secteur_fp = Column(Integer)
    the_geom = Column(Geometry)

    l_secteur = relationship(u'LSecteur')


class LSecteur(Base):
    __tablename__ = 'l_secteurs'
    __table_args__ = {u'schema': 'layers'}

    nom_secteur = Column(String(50))
    id_secteur = Column(Integer, primary_key=True)
    the_geom = Column(Geometry)
