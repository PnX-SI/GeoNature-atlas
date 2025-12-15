# coding: utf-8
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class TCorDatasetActor(db.Model):
    __tablename__ = "cor_dataset_actor"
    __table_args__ = {"schema": "gn_meta"}

    id_cda: Mapped[int] = mapped_column(primary_key=True)
    id_dataset: Mapped[int] = mapped_column()
    id_role: Mapped[int] = mapped_column()
    id_organism: Mapped[int] = mapped_column()
    id_nomenclature_actor_role: Mapped[int] = mapped_column()
