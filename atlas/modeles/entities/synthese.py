# coding: utf-8
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from geoalchemy2 import Geometry
from atlas.env import db
import datetime


class Syntheseff(db.Model):
    __tablename__ = "syntheseff"
    __table_args__ = {"schema": "synthese"}

    id_synthese: Mapped[int] = mapped_column(primary_key=True)
    id_dataset: Mapped[int] = mapped_column()
    cd_nom: Mapped[int] = mapped_column()
    dateobs: Mapped[datetime.date] = mapped_column()
    observateurs: Mapped[str] = mapped_column(String)
    altitude_retenue: Mapped[int] = mapped_column()
    the_geom_point: Mapped[object] = mapped_column(Geometry("POINT", 4326))
    effectif_total: Mapped[int] = mapped_column()
    diffusion_level: Mapped[int] = mapped_column()