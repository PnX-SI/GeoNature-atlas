# coding: utf-8
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class VmMois(db.Model):
    __tablename__ = "vm_mois"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    _01: Mapped[int] = mapped_column()
    _02: Mapped[int] = mapped_column()
    _03: Mapped[int] = mapped_column()
    _04: Mapped[int] = mapped_column()
    _05: Mapped[int] = mapped_column()
    _06: Mapped[int] = mapped_column()
    _07: Mapped[int] = mapped_column()
    _08: Mapped[int] = mapped_column()
    _09: Mapped[int] = mapped_column()
    _10: Mapped[int] = mapped_column()
    _11: Mapped[int] = mapped_column()
    _12: Mapped[int] = mapped_column()
