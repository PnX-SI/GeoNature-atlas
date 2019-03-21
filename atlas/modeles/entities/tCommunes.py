# coding: utf-8
from sqlalchemy import BigInteger, Boolean, Column, ForeignKey, Integer, String
from geoalchemy2 import Geometry
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base



Base = declarative_base()
metadata = Base.metadata


class LCommune(Base):
    __tablename__ = 'l_communes'
    __table_args__ = {u'schema': 'layers'}

    insee = Column(String(5), primary_key=True)
    commune_maj = Column(String(50))
    commune_min = Column(String(50))
    the_geom = Column(Geometry)