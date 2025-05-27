# coding: utf-8
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class VmAltitudes(Base):
    __tablename__ = "vm_altitudes"
    __table_args__ = {"schema":"atlas"}
    
    cd_ref = Column(Integer, primary_key = True)
    _0_500 = Column(Integer)
    _500_1000 = Column(Integer)
    _1000_1500 = Column(Integer)
    _1500_2000 = Column(Integer)
    _2000_2500 = Column(Integer)
    _2500_3000 = Column(Integer)
    _3000_3500 = Column(Integer)
    _3500_4000 = Column(Integer)
