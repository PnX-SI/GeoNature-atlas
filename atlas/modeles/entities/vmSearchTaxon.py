# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmSearchTaxon(Base):
    __tablename__ = "vm_search_taxon"
    __table_args__ = {"schema": "atlas"}
    cd_ref = Column("cd_ref", Integer, primary_key=True, unique=True)
    cd_nom = Column("cd_nom", Integer)
    display_name = Column("display_name", String)
    search_name = Column("search_name", String)
