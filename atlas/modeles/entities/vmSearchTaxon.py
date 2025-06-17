# coding: utf-8
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


class VmSearchTaxon(Base):
    __tablename__ = "vm_search_taxon"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    cd_nom: Mapped[int] = mapped_column()
    search_name: Mapped[str] = mapped_column(String)
