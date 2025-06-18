# -*- coding:utf-8 -*-
from sqlalchemy import String, Float, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import relationship
from atlas.env import db

from typing import List


class VmTaxons(db.Model):
    __tablename__ = "vm_taxons"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    regne: Mapped[str] = mapped_column(String(20))
    phylum: Mapped[str] = mapped_column(String(50))
    classe: Mapped[str] = mapped_column(String(50))
    ordre: Mapped[str] = mapped_column(String(50))
    famille: Mapped[str] = mapped_column(String(50))
    cd_taxsup: Mapped[int] = mapped_column()
    lb_nom: Mapped[str] = mapped_column(String(100))
    lb_auteur: Mapped[str] = mapped_column(String(250))
    nom_complet: Mapped[str] = mapped_column(String(255))
    nom_valide: Mapped[str] = mapped_column(String(255))
    nom_vern: Mapped[str] = mapped_column(String(1000))
    nom_vern_eng: Mapped[str] = mapped_column(String(500))
    group1_inpn: Mapped[str] = mapped_column(String(50))
    group2_inpn: Mapped[str] = mapped_column(String(50))
    nom_complet_html: Mapped[str] = mapped_column(String(500))
    id_rang: Mapped[str] = mapped_column(String(10))
    patrimonial: Mapped[str] = mapped_column(String(255))
    protection_stricte: Mapped[str] = mapped_column(String(255))
    yearmin: Mapped[float] = mapped_column(Float(53))
    yearmax: Mapped[float] = mapped_column(Float(53))
    nb_obs: Mapped[int] = mapped_column()
    attributs: Mapped[List["VmCorTaxonAttribut"]] = relationship(
        "VmCorTaxonAttribut", back_populates="taxon"
    )


class VmCorTaxonAttribut(db.Model):
    __tablename__ = "vm_cor_taxon_attribut"
    __table_args__ = {"schema": "atlas"}

    id_attribut: Mapped[int] = mapped_column(primary_key=True)
    cd_ref: Mapped[int] = mapped_column(ForeignKey("atlas.vm_taxons.cd_ref"), primary_key=True)
    valeur_attribut: Mapped[str] = mapped_column(Text)
    taxon: Mapped["VmTaxons"] = relationship("VmTaxons", back_populates="attributs")


class VmTaxonsMostView(db.Model):
    __tablename__ = "vm_taxons_plus_observes"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    nb_obs: Mapped[int] = mapped_column()
    lb_nom: Mapped[str] = mapped_column(String(250))
    group2_inpn: Mapped[str] = mapped_column(String(50))
    nom_vern: Mapped[str] = mapped_column(String(1000))
    id_media: Mapped[int] = mapped_column()
    url: Mapped[str] = mapped_column(String(255))
    chemin: Mapped[str] = mapped_column(String(255))
    id_type: Mapped[int] = mapped_column()
