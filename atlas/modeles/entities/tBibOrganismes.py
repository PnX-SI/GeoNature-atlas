# coding: utf-8
from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column
import datetime
import uuid

class Base(DeclarativeBase):
    pass

class TBibOrganismes(Base):
    __tablename__ = "bib_organismes"
    __table_args__ = {"schema" : "utilisateurs"}

    id_organisme: Mapped[int] = mapped_column(primary_key = True)
    uuid_organisme: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), unique=True)

    additional_data: Mapped[dict] = mapped_column(JSONB, default=dict)
    adresse_organisme: Mapped[str] = mapped_column(String(128))
    cp_organism: Mapped[str] = mapped_column(String(5))
    email_organisme: Mapped[str] = mapped_column(String(100))
    fax_organisme: Mapped[str] = mapped_column(String(14))
    id_parent: Mapped[int] = mapped_column() 
    meta_create_date: Mapped[datetime.date] = mapped_column()
    meta_update_date: Mapped[datetime.date] = mapped_column()
    nom_organisme: Mapped[str] = mapped_column(String(500))
    tel_organisme: Mapped[str] = mapped_column(String(14))
    url_logo: Mapped[str] = mapped_column(String(255))
    url_organisme: Mapped[str] = mapped_column(String(255))
    ville_organisme: Mapped[str] = mapped_column(String(100))
