# coding: utf-8
from sqlalchemy import Column, Integer, String, Table, Date
from sqlalchemy.ext.declarative import declarative_base
from geoalchemy2 import Geometry


Base = declarative_base()


class Syntheseff(Base):
    __tablename__ = "syntheseff"
    __table_args__ = {"schema" : "synthese"}

    id_synthese = Column(Integer, primary_key=True)
    id_dataset = Column(Integer)
    cd_nom = Column(Integer)
    dateobs = Column(Date)
    observateurs = Column(String)
    altitude_retenue = Column(Integer)
    the_geom_point = Column(Geometry("POINT", 4326))
    effectif_total = Column(Integer)
    diffusion_level = Column(Integer)