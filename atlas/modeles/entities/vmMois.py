# coding: utf-8
from sqlalchemy import Column, Integer, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base

from atlas.env import db

metadata = MetaData()
Base = declarative_base()


class VmMois(Base):
    __tablename__ = "vm_mois"
    __table_args__ = {"schema": "atlas"}
    cd_ref = (Column("cd_ref", Integer, primary_key=True, unique=True),)
    _01 = Column("_01", Integer)
    _02 = Column("_02", Integer)
    _03 = Column("_03", Integer)
    _04 = Column("_04", Integer)
    _05 = Column("_05", Integer)
    _06 = Column("_06", Integer)
    _07 = Column("_07", Integer)
    _08 = Column("_08", Integer)
    _09 = Column("_09", Integer)
    _10 = Column("_10", Integer)
    _11 = Column("_11", Integer)
    _12 = Column("_12", Integer)
