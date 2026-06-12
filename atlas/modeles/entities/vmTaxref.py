# coding: utf-8
from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class VmTaxref(db.Model):
    __tablename__ = "vm_taxref"
    __table_args__ = {"schema": "atlas"}

    cd_nom: Mapped[int] = mapped_column(primary_key=True)
    id_statut: Mapped[str] = mapped_column(String(1))
    id_habitat: Mapped[int] = mapped_column()
    id_rang: Mapped[str] = mapped_column(String(4))
    regne: Mapped[str] = mapped_column(String(20))
    phylum: Mapped[str] = mapped_column(String(50))
    classe: Mapped[str] = mapped_column(String(50))
    ordre: Mapped[str] = mapped_column(String(50))
    famille: Mapped[str] = mapped_column(String(50))
    sous_famille: Mapped[str] = mapped_column(String(50))
    tribu: Mapped[str] = mapped_column(String(50))
    cd_taxsup: Mapped[int] = mapped_column()
    cd_sup: Mapped[int] = mapped_column()
    cd_ref: Mapped[int] = mapped_column(index=True)
    lb_nom: Mapped[str] = mapped_column(String(100), index=True)
    lb_auteur: Mapped[str] = mapped_column(String(250))
    nom_complet: Mapped[str] = mapped_column(String(255), index=True)
    nom_complet_html: Mapped[str] = mapped_column(String(500))
    nom_valide: Mapped[str] = mapped_column(String(255), index=True)
    nom_vern: Mapped[str] = mapped_column(String(1000))
    nom_vern_eng: Mapped[str] = mapped_column(String(500))
    group1_inpn: Mapped[str] = mapped_column(String(50))
    group2_inpn: Mapped[str] = mapped_column(String(50))
    url: Mapped[str] = mapped_column(Text)
    group3_inpn: Mapped[str] = mapped_column(String(250))
