# -*- coding:utf-8 -*-

from sqlalchemy.sql import text, func, select, or_
from atlas.modeles.entities.vmMois import VmMois
from atlas.app import create_app
from atlas.env import db

def getMonthlyObservationsChilds(session, cd_ref):
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    mesMois = (
        session.query(
            func.sum(VmMois._01).label("_01"),
            func.sum(VmMois._02).label("_02"),
            func.sum(VmMois._03).label("_03"),
            func.sum(VmMois._04).label("_04"),
            func.sum(VmMois._05).label("_05"),
            func.sum(VmMois._06).label("_06"),
            func.sum(VmMois._07).label("_07"),
            func.sum(VmMois._08).label("_08"),
            func.sum(VmMois._09).label("_09"),
            func.sum(VmMois._10).label("_10"),
            func.sum(VmMois._11).label("_11"),
            func.sum(VmMois._12).label("_12"),
        )
        .filter(
            or_(VmMois.cd_ref.in_(childs_ids), VmMois.cd_ref == cd_ref)
        )
    )
    for inter in mesMois:
        return [
            {"mois": "Janvier", "value": inter._01},
            {"mois": "Fevrier", "value": inter._02},
            {"mois": "Mars", "value": inter._03},
            {"mois": "Avril", "value": inter._04},
            {"mois": "Mai", "value": inter._05},
            {"mois": "Juin", "value": inter._06},
            {"mois": "Juillet", "value": inter._07},
            {"mois": "Aout", "value": inter._08},
            {"mois": "Septembre", "value": inter._09},
            {"mois": "Octobre", "value": inter._10},
            {"mois": "Novembre", "value": inter._11},
            {"mois": "Decembre", "value": inter._12},
        ]      