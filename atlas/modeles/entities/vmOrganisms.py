# -*- coding:utf-8 -*-

from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class VmOrganisms(db.Model):
    __tablename__ = "vm_cor_taxon_organism"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(ForeignKey("atlas.vm_taxons.cd_ref"), primary_key=True)
    id_organism: Mapped[int] = mapped_column(primary_key=True, unique=True)

    nb_observations: Mapped[int] = mapped_column()
    nom_organism: Mapped[str] = mapped_column(String(500))
    adresse_organism: Mapped[str] = mapped_column(String(128))
    cp_organism: Mapped[str] = mapped_column(String(5))
    ville_organism: Mapped[str] = mapped_column(String(100))
    tel_organism: Mapped[str] = mapped_column(String(14))
    email_organism: Mapped[str] = mapped_column(String(100))
    url_organism: Mapped[str] = mapped_column(String(255))
    url_logo: Mapped[str] = mapped_column(String(255))