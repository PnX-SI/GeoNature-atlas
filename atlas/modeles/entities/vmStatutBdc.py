from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class VmStatutBdc(Base):
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
