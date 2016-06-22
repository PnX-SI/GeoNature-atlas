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
    listAlti = list()
    interAlti = dict()
    for r in session.query(VmAltitudes).filter(VmAltitudes.cd_ref==cd_ref).all():
        interAlti = r.__dict__.copy()
        del interAlti['_sa_instance_state']
        del interAlti['cd_ref']
    
    for key, value in interAlti.items():
        key=str(key)
        key= key[1:]
        key = key.replace('_', '-')
        temp = {"altitude": key, "value": value}
        listAlti.append(temp)
    return listAlti
