from typing import List

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from atlas.env import db


class VmStatutBdc(db.Model):
    __tablename__ = "vm_bdc_statut"
    __table_args__ = {"schema": "atlas"}

    id: Mapped[int] = mapped_column(primary_key=True)
    cd_ref: Mapped[int] = mapped_column()
    rq_statut: Mapped[str] = mapped_column(String(1000))
    code_statut: Mapped[str] = mapped_column(String(50))
    label_statut: Mapped[str] = mapped_column(String(250))
    cd_type_statut: Mapped[str] = mapped_column(String(50))
    lb_type_statut: Mapped[str] = mapped_column(String(250))
    cd_sig: Mapped[str] = mapped_column(String(50))
    lb_adm_tr: Mapped[str] = mapped_column(String(250))


class TOrdreListeRouge(db.Model):
    __tablename__ = "order_liste_rouge"
    __table_args__ = {"schema": "atlas"}
    id_order: Mapped[int] = mapped_column(primary_key=True)
    code_statut: Mapped[str] = mapped_column(primary_key=True)


class CorTaxonStatutArea(db.Model):
    __tablename__ = "vm_cor_taxon_statut_area"
    __table_args__ = {"schema": "atlas"}
    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    id_area: Mapped[int] = mapped_column(primary_key=True)
    statut_menace: Mapped[str] = mapped_column()
    niveau_application_menace: Mapped[str] = mapped_column()
    protege: Mapped[bool] = mapped_column()
