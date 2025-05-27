# coding: utf-8
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class TBibAltitudes(Base):
    __tablename__ = "bib_altitudes"
    __table_args__ = {"schema": "atlas"}

    id_altitude = Column(Integer, primary_key=True)
    altitude_min = Column(Integer)
    altitude_max = Column(Integer)
    label_altitude = Column(String(255))