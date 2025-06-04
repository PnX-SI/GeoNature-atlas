# coding: utf-8
from sqlalchemy import Column, Integer, String, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import UUID, JSONB

Base = declarative_base()

class TBibOrganismes(Base):
    __tablename__ = "bib_organismes"
    __table_args__ = {"schema" : "utilisateurs"}

    id_organisme = Column(Integer, primary_key =  True)
    uuid_organisme = Column(UUID(as_uuid=True), unique=True)

    additional_data = Column(JSONB, default=dict)
    adresse_organisme = Column(String(128))
    cp_organism = Column(String(5))
    email_organisme = Column(String(100))
    fax_organisme = Column(String(14))
    id_parent = Column(Integer)
    meta_create_date = Column(Date)
    meta_update_date = Column(Date)
    nom_organisme = Column(String(500))
    tel_organisme = Column(String(14))
    url_logo = Column(String(255))
    url_organisme = Column(String(255))
    ville_organisme = Column(String(100))