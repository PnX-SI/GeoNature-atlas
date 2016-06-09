#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmObservations import VmObservations
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker

session = manage.loadSession()

def searchObservation(cd_ref):
    return = session.query(VmObservations.geojson_point).filter(VmObservations.cd_ref == cd_ref).all()



