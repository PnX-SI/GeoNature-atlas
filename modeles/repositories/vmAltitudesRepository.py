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
        
    # request = session.query(VmAltitudes).filter(VmAltitudes.cd_ref == cd_ref).all()
    # inter = request[0]
    # listAlti = list()
    # keyList = inter.__dict__.keys()
    # i = 3
    # while i<len(keyList):
    #     value = getattr(inter, keyList[i])
    #     temp = {"altitude": keyList[i], "value": str(value)}
    #     listAlti.append(temp)
    #     i = i+1
    # return listAlti

    
    # for key, value in inter.items():
    #     key=str(key)
    #     key= key[1:]
    #     key = key.replace('_', '-')
    #     value = type(value)
    #     # value = int(value)
    #     # temp = jsonify(altitude=key,value=str(value))
    #     temp = {"altitude": key, "value": value}
    #     listAlti.append(temp)
    # return listAlti


    # return [
    # {'altitude': '0 - 500' , 'value' : inter.altinf500},
    # {'altitude': '500-1000','value': inter.alt500_1000},
    # {'altitude': '1000-1500', 'value': inter.alt1000_1500},
    # {'altitude': '1500-2000', 'value': inter.alt1500_2000},
    # {'altitude': '2000-2500', 'value' : inter.alt2000_2500},
    # {'altitude': '2500-3000', 'value': inter.alt2500_3000},
    # {'altitude':'3000-3500', 'value': inter.alt3000_3500},
    # {'altitude': '3500-4000', 'value': inter.alt3500_4000},
    # {'altitude': '+ 4000', 'value': inter.alt_sup4000}
    # ]

