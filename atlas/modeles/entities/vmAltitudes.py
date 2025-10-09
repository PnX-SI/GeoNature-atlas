# coding: utf-8
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class VmAltitudes(db.Model):
    __tablename__ = "vm_altitudes"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    _0_500: Mapped[int] = mapped_column()
    _500_1000: Mapped[int] = mapped_column()
    _1000_1500: Mapped[int] = mapped_column()
    _1500_2000: Mapped[int] = mapped_column()
    _2000_2500: Mapped[int] = mapped_column()
    _2500_3000: Mapped[int] = mapped_column()
    _3000_3500: Mapped[int] = mapped_column()
    _3500_4000: Mapped[int] = mapped_column()
