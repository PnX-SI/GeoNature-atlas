# coding: utf-8

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class CorSensitivityAreaType(db.Model):
    __tablename__ = "cor_sensitivity_area_type"
    __table_args__ = {"schema": "atlas"}

    area_type_code: Mapped[str] = mapped_column(String(50), primary_key=True)
    sensitivity_code: Mapped[str] = mapped_column(String(50))
