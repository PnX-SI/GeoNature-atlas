#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import manage 
from modeles import utils

session = manage.loadSession()

tableAltitudes = utils.GenericTable('atlas.vm_altitudes', 'atlas')
dfCdRef = tableAltitudes.tableDef.columns['cd_ref']
def getAltitudes(cd_ref):
    keyList = tableAltitudes.tableDef.columns.keys()
    mesAltitudes = session.query(tableAltitudes.tableDef).filter(dfCdRef==cd_ref).all()
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
