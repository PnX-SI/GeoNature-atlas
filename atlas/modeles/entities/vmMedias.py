# coding: utf-8
from sqlalchemy import Column, MetaData, String, Table, Integer, ForeignKey, Text, Date
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmMedias(Base):
    __tablename__ = "vm_medias"
    __table_args__ = {"schema": "atlas"}

    id_media = Column(Integer, primary_key=True)
    cd_ref = Column(Integer)
    titre = Column(String(255))
    url = Column(String(255))
    chemin = Column(String(255))
    auteur = Column(String(1000))
    desc_media = Column(Text)
    date_media = Column(Date)
    id_type = Column(Integer)
    licence = Column(String(100))
    source = Column(String(25))
