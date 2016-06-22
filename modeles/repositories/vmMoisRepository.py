from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmMois import VmMois
from sqlalchemy import distinct, func, extract
from sqlalchemy.orm import sessionmaker
import ast
from datetime import datetime

session = manage.loadSession()


def getMonthlyObservations(cd_ref):
    request = session.query(VmMois).filter(VmMois.cd_ref==cd_ref).all()
    inter = request[0]
    return [
    {'mois': "Janvier", 'value': inter._01},
    {'mois': "Fevrier", 'value': inter._02},
    {'mois': "Mars", 'value': inter._03},
    {'mois': "Avril", 'value': inter._04},
    {'mois': "Mai", 'value': inter._05},
    {'mois': "Juin", 'value': inter._06},
    {'mois': "Juillet", 'value': inter._07},
    {'mois': "Aout", 'value': inter._08},
    {'mois': "Septembre", 'value': inter._09},
    {'mois': "Octobre", 'value': inter._10},
    {'mois': "Novembre", 'value': inter._11},
    {'mois': "Decembre", 'value': inter._12}
    ]