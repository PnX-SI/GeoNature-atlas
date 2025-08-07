# coding: utf-8
from sqlalchemy import Column, MetaData, String, Table, Integer, ForeignKey, Text, Date
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmMedias(Base):
    __tablename__ = "vm_medias"
    __table_args__ = {"schema": "atlas"}
    id_media = Column("id_media", Integer(), primary_key=True, unique=True)
    cd_ref = Column("cd_ref", Integer())
    titre = Column("titre", String(255))
    url = Column("url", String(255))
    chemin = Column("chemin", String(255))
    auteur = Column("auteur", String(1000))
    desc_media = Column("desc_media", Text())
    date_media = Column("date_media", Date())
    id_type = Column("id_type", Integer())
    licence = Column("licence", String(100))
    source = Column("source", String(25))
