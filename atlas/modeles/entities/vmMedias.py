# coding: utf-8
from sqlalchemy import Column, MetaData, String, Table, Integer, ForeignKey, Text, Date
from sqlalchemy.ext.declarative import declarative_base

from atlas.utils import engine

metadata = MetaData()
Base = declarative_base()


class VmMedias(Base):
    __table__ = Table(
        "vm_medias",
        metadata,
        Column("id_media", Integer(), primary_key=True, unique=True),
        Column("cd_ref", Integer()),
        Column("titre", String(255)),
        Column("url", String(255)),
        Column("chemin", String(255)),
        Column("auteur", String(1000)),
        Column("desc_media", Text()),
        Column("date_media", Date()),
        Column("id_type", Integer()),
        Column("licence", String(100)),
        Column("source", String(25)),
        schema="atlas",
        autoload=True,
        autoload_with=engine,
    )
