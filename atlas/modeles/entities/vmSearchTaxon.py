# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmSearchTaxon(Base):
    __tablename__ = "vm_search_taxon"
    __table_args__ = {'schema' : 'atlas'}
    cd_ref = Column(Integer, primary_key=True)
    cd_nom = Column(Integer)
    search_name = Column(String)
