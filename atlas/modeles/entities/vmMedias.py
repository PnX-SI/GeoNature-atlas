# coding: utf-8
from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db
import datetime


class VmMedias(db.Model):
    __tablename__ = "vm_medias"
    __table_args__ = {"schema": "atlas"}

    id_media: Mapped[int] = mapped_column(primary_key=True)
    cd_ref: Mapped[int] = mapped_column()
    titre: Mapped[str] = mapped_column(String(255))
    url: Mapped[str] = mapped_column(String(255))
    chemin: Mapped[str] = mapped_column(String(255))
    auteur: Mapped[str] = mapped_column(String(1000))
    desc_media: Mapped[str] = mapped_column(Text)
    date_media: Mapped[datetime.date] = mapped_column()
    id_type: Mapped[int] = mapped_column()
    licence: Mapped[str] = mapped_column(String(100))
    source: Mapped[str] = mapped_column(String(25))