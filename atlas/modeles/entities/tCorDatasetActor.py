# coding: utf-8
from sqlalchemy import Column, Integer
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()


class TCorDatasetActor(Base):
    __tablename__ = "cor_dataset_actor"
    __table_args__ = {"schema" : "gn_meta"}

    id_cda = Column(Integer, primary_key = True)
    id_dataset = Column(Integer)
    id_role = Column(Integer)
    id_organism = Column(Integer)
    id_nomenclature_actor_role = Column(Integer)
