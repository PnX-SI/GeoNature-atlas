# coding: utf-8
from geoalchemy2.types import Geometry
from sqlalchemy import Integer, String, Text, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import DeclarativeBase

from typing import List
import datetime

class Base(DeclarativeBase):
    pass

class VmObservations(Base):
    __tablename__ = "vm_observations"
    __table_args__ = {"schema":"atlas"}

    id_observation: Mapped[int] = mapped_column(primary_key = True) 
    dateobs: Mapped[datetime.date] = mapped_column(index=True)
    observateurs: Mapped[str] = mapped_column(String(255)) 
    altitude_retenue: Mapped[int] = mapped_column(index=True)
    cd_ref: Mapped[int] = mapped_column(index=True)
    the_geom_point: Mapped[object] = mapped_column(Geometry(geometry_type="POINT", srid=4326))
    geojson_point: Mapped[str] = mapped_column(Text)
    cd_sensitivity: Mapped[str] = mapped_column(String(255))
    id_dataset: Mapped[int] = mapped_column()
    insee: Mapped[str] = mapped_column(Text)

    def as_dict(self):
        return {
            "dateobs": str(self.dateobs),
            "year": self.dateobs.year if self.dateobs else None,
            "id_observation": self.id_observation,
            "observateurs": self.observateurs,
            "altitude_retenue": self.altitude_retenue,
            "cd_ref": self.cd_ref,
            "cd_sensitivity": self.cd_sensitivity,
        }

class VmObservationsMailles(Base):
    """
    Table des observations par maille
    """
    __tablename__ = "vm_observations_mailles"
    __table_args__ = {"schema" : "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True, index=True)
    annee: Mapped[str] = mapped_column(String(1000), primary_key=True, index=True)
    id_maille: Mapped[int] = mapped_column(primary_key=True, index=True)
    nbr: Mapped[int] = mapped_column()
    id_observations: Mapped[List[int]] = mapped_column(ARRAY(Integer))
    type_code: Mapped[str] = mapped_column(String(25))
