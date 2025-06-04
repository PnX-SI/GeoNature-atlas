from sqlalchemy import Column, Integer, String, Table, Date
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class VmStatutBdc(Base):
    __tablename__ = "vm_bdc_statut"
    __table_args__ = {"schema" : "atlas"}

    id = Column(Integer, primary_key = True)
    cd_ref = Column(Integer)
    rq_statut = Column(String(1000))
    code_statut = Column(String(50))
    label_statut = Column(String(250))
    cd_type_statut = Column(String(50))
    lb_type_statut = Column(String(250))
    cd_sig = Column(String(50))
    lb_adm_tr = Column(String(250))