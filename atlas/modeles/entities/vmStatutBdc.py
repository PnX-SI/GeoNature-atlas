from typing import List

from sqlalchemy import String, Table, Column, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from atlas.env import db
from atlas.modeles.entities.vmAreas import VmAreas


# bdc_statut_cor_text_area = Table(
#     "bdc_statut_cor_text_area",
#     db.metadata,
#     Column("id_text", ForeignKey("atlas.vm_bdc_statut.id_text")),
#     Column("id_area", ForeignKey("atlas.vm_bib_areas_types.id_area")),
#     schema="atlas",
# )


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

class CorTaxonAreaMenace(db.Model):
    __tablename__ = "cor_taxon_area_menace"
    __table_args__ = {"schema": "atlas"}
    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    code_statut: Mapped[str] = mapped_column(primary_key=True)
    id_area: Mapped[int] = mapped_column(primary_key=True)


