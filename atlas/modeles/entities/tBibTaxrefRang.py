# coding: utf-8
from sqlalchemy import Column, Integer, String, Table
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class TBibTaxrefRang(Base):
    __tablename__ = "bib_taxref_rangs"
    __table_args__ = {"schema": "atlas"}

    id_rang = Column(String(4), primary_key=True, nullable=False)
    nom_rang = Column(String(20), nullable=False)
    tri_rang = Column(Integer)
