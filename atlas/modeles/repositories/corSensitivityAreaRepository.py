from sqlalchemy import select

from atlas.env import db
from atlas.modeles.entities.vmAreas import VmBibAreasTypes
from atlas.modeles.entities.CorSensitivity import CorSensitivityAreaType


def get_sensitivity_areas_level():
    q = select(CorSensitivityAreaType, VmBibAreasTypes).join(
        CorSensitivityAreaType, CorSensitivityAreaType.area_type_code == VmBibAreasTypes.type_code
    )
    data = db.session.execute(q).all()
    return {
        d[0].sensitivity_code: {"area_code": d[0].area_type_code, "area_name": d[1].type_name}
        for d in data
    }
