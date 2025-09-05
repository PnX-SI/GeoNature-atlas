# coding: utf-8
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db

class TBibTaxrefRang(db.Model):
    __tablename__ = "bib_taxref_rangs"
    __table_args__ = {"schema": "atlas"}

    id_rang: Mapped[str] = mapped_column(String(4), primary_key=True, nullable=False)
    nom_rang: Mapped[str] = mapped_column(String(20), nullable=False)
    tri_rang: Mapped[int] = mapped_column()