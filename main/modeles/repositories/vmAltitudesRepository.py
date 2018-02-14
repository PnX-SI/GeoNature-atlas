#! /usr/bin/python
# -*- coding:utf-8 -*-

from .. import utils
from sqlalchemy.sql import text


tableAltitudes = utils.GenericTable('atlas.vm_altitudes', 'atlas')
dfCdRef = tableAltitudes.tableDef.columns['cd_ref']
keyList = tableAltitudes.tableDef.columns.keys()


# la keylist contient un champs cd_ref, donc on boucle dessus en enlevant ce champs
def getAltitudes(cd_ref):
    mesAltitudes = session.query(tableAltitudes.tableDef).filter(dfCdRef == cd_ref).all()
    mesAltitudes = mesAltitudes[0]
    altiList = list()
    for i in range(len(keyList)):
        key = str(keyList[i])
        key  = key[1:]
        key = key.replace('_', '-')
        if keyList[i] != 'cd_ref':
            temp = {
                "altitude": key,
                "value": getattr(mesAltitudes, keyList[i])
            }
            altiList.insert(i, temp)
    return altiList


def getAltitudesChilds(connection, cd_ref):
    # construction du select  de la requete a partir des cles de la table
    sumSelect = str()
    for i in range(len(keyList)):
        if keyList[i] != 'cd_ref':
            if i < len(keyList) -1:
                sumSelect = sumSelect + "SUM(" + keyList[i]+ ") AS " + keyList[i]+ ", "
            else:
                sumSelect = sumSelect + "SUM(" + keyList[i]+ ") AS " + keyList[i]

    sql =  "select " + sumSelect + " \
    from atlas.vm_altitudes alt \
    where alt.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR alt.cd_ref = :thiscdref".encode('UTF-8')
    mesAltitudes = connection.execute(text(sql), thiscdref=cd_ref)

    altiList = list()
    for a in mesAltitudes:
        for i in range(len(keyList)):
            newKey = str(keyList[i])
            newKey = newKey[1:]
            newKey = newKey.replace('_', '-')
            if keyList[i] != 'cd_ref':
                temp = {"altitude": newKey, "value": getattr(a, keyList[i])}
                altiList.insert(i, temp)

    return altiList