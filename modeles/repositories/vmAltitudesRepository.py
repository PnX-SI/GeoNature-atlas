#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmAltitudes import VmAltitudes
from sqlalchemy import distinct, func, extract
from sqlalchemy.orm import sessionmaker

session = manage.loadSession()

def getAltitudes(cd_ref):
    request = session.query(VmAltitudes).filter(VmAltitudes.cd_ref == cd_ref).all()
    inter = request[0]
    return [
    {'altitude': '0 - 500' , 'value' : inter.altinf500},
    {'altitude': '500-1000','value': inter.alt500_1000},
    {'altitude': '1000-1500', 'value': inter.alt1000_1500},
    {'altitude': '1500-2000', 'value': inter.alt1500_2000},
    {'altitude': '2000-2500', 'value' : inter.alt2000_2500},
    {'altitude': '2500-3000', 'value': inter.alt2500_3000},
    {'altitude':'3000-3500', 'value': inter.alt3000_3500},
    {'altitude': '3500-4000', 'value': inter.alt3500_4000},
    {'altitude': '+ 4000', 'value': inter.alt_sup4000}
    ]

