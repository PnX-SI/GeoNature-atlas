# coding: utf-8
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class TBibAltitudes(db.Model):
    __tablename__ = "bib_altitudes"
    __table_args__ = {"schema": "atlas"}

    id_altitude: Mapped[int] = mapped_column(primary_key=True)
    altitude_min: Mapped[int] = mapped_column()
    altitude_max: Mapped[int] = mapped_column()
    label_altitude: Mapped[str] = mapped_column(String(255))
