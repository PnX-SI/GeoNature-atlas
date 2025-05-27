# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

Base = declarative_base()


class VmMois(Base):
    __tablename__ = "vm_mois"
    __table_args__ = {"schema": "atlas"}

    cd_ref = Column(Integer, primary_key=True)
    _01 = Column(Integer)
    _02 = Column(Integer)
    _03 = Column(Integer)
    _04 = Column(Integer)
    _05 = Column(Integer)
    _06 = Column(Integer)
    _07 = Column(Integer)
    _08 = Column(Integer)
    _09 = Column(Integer)
    _10 = Column(Integer)
    _11 = Column(Integer)
    _12 = Column(Integer)
