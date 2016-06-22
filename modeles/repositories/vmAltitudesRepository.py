#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmAltitudes import VmAltitudes
from sqlalchemy import distinct, func, extract
from sqlalchemy.orm import sessionmaker
import json
from flask import jsonify

session = manage.loadSession()

def getAltitudes(cd_ref):
    keyList = VmAltitudes.__table__.columns.keys()

    mesAltitudes = session.query(VmAltitudes).filter(VmAltitudes.cd_ref==cd_ref).all()
    mesAltitudes = mesAltitudes[0]
    altiList = list()
    for i in range(len(keyList)):
        key = str(keyList[i])
        key= key[1:]
        key = key.replace('_', '-')
        if keyList[i] != 'cd_ref':
            temp = {"altitude": key, "value":getattr(mesAltitudes, keyList[i]) } 
            altiList.insert(i, temp)
    return altiList
