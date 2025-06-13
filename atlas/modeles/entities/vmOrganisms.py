# -*- coding:utf-8 -*-

from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class VmOrganisms(Base):
    __tablename__ = "vm_cor_taxon_organism"
    __table_args__ = {'schema' : 'atlas'}
    
    id_organism: Mapped[int] = mapped_column(primary_key=True, unique=True)
    nb_observations:Mapped[int] = mapped_column()
    nom_organism:Mapped[str] = mapped_column(String(500))
    adresse_organism: Mapped[str] = mapped_column(String(128))
    cp_organism: Mapped[str] = mapped_column(String(5))
    ville_organism: Mapped[str] = mapped_column(String(100))
    tel_organism: Mapped[str] = mapped_column(String(14))
    email_organism: Mapped[str] = mapped_column(String(100))
    url_organism: Mapped[str] = mapped_column(String(255))
    url_logo: Mapped[str] = mapped_column(String(255))
    cd_ref: Mapped[int] = mapped_column()