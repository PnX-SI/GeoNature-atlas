#! /usr/bin/python
# -*- coding:utf-8 -*-

from .. import utils
from ...configuration import config
from ..entities.vmObservations import VmObservations
from ..entities.tCommunes import LCommune
from ..entities.vmTaxref import VmTaxref
from ..entities.vmTaxons import VmTaxons
import tCommunesRepository
from sqlalchemy import distinct, func, extract, desc
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker
import ast
from datetime import datetime
import random


currentYear = datetime.now().year



def searchObservation(cd_ref):
    observations = session.query(VmObservations).filter(VmObservations.cd_ref == cd_ref).all()
    return  toGeoJsonTaxon(observations)


def searchObservationsChilds(connection, cd_ref):
    sql = "select obs.id_synthese, \
    obs.geojson_point, \
    obs.cd_ref, \
    obs.dateobs, \
    obs.observateurs, \
    obs.altitude_retenue, \
    obs.effectif_total \
    from atlas.vm_observations obs \
    where obs.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR obs.cd_ref = :thiscdref".encode('UTF-8')
    observations = connection.execute(text(sql), thiscdref = cd_ref)
    obsList = list()
    for o in observations:
        temp = {'id_synthese':o.id_synthese,'geojson_point':ast.literal_eval(o.geojson_point),'cd_ref':o.cd_ref,'dateobs':str(o.dateobs),\
                'observateurs':o.observateurs,'altitude_retenue':o.altitude_retenue,
                'effectif_total':o.effectif_total,'year':o.dateobs.year}
        obsList.append(temp)
    return obsList


def firstObservationChild(connection, cd_ref):
    sql = "select min(taxons.yearmin) as yearmin \
    from atlas.vm_taxons taxons \
    join atlas.vm_taxref taxref ON taxref.cd_ref=taxons.cd_ref \
    where taxons.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR taxons.cd_ref = :thiscdref".encode('UTF-8')
    req = connection.execute(text(sql), thiscdref = cd_ref)
    for r in req:
      return r.yearmin

    
def lastObservations(connection, mylimit, idPhoto):
    sql = "SELECT obs.*, \
    tax.lb_nom, tax.nom_vern, tax.group2_inpn, \
    medias.url \
    FROM atlas.vm_observations obs \
    JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref \
    LEFT JOIN atlas.vm_medias medias ON medias.cd_ref = obs.cd_ref AND medias.id_media = :thisidphoto\
    ORDER BY obs.dateobs DESC \
    LIMIT :thislimit "

    observations = connection.execute(text(sql), thislimit = mylimit, thisidphoto=idPhoto)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            inter = o.nom_vern.split(',')
            taxon = inter[0] +' | '+ o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_synthese' : o.id_synthese,
                'cd_ref': o.cd_ref,
                'dateobs': str(o.dateobs),
                'altitude_retenue' : o.altitude_retenue,
                'effectif_total' : o.effectif_total,
                'taxon': taxon,
                'geojson_point':ast.literal_eval(o.geojson_point),
                'group2_inpn': utils.deleteAccent(o.group2_inpn),
                'urlImage' : o.url
                }
        obsList.append(temp)
    return obsList


def lastObservationsCommune(connection, mylimit, insee):
    sql = "SELECT o.id_synthese, o.cd_ref, o.dateobs, o.altitude_retenue,o.geojson_point, o.effectif_total, t.lb_nom, t.nom_vern \
    FROM atlas.vm_observations o \
    JOIN layers.l_communes c ON ST_Intersects(st_transform(o.the_geom_point, 2154), c.the_geom) \
    JOIN atlas.vm_taxons t ON  o.cd_ref=t.cd_ref \
    WHERE c.insee = :thisInsee \
    ORDER BY o.dateobs DESC \
    LIMIT 100"
    observations = connection.execute(text(sql), thisInsee = insee)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_synthese' : o.id_synthese,
                'cd_ref': o.cd_ref,
                'dateobs': str(o.dateobs),
                'altitude_retenue' : o.altitude_retenue,
                'effectif_total' : o.effectif_total,
                'taxon': taxon,
                'geojson_point':ast.literal_eval(o.geojson_point),
                }
        obsList.append(temp)
    return obsList



def getObservationTaxonMaille(connection, insee, cd_ref):
    sql = "SELECT o.id_synthese, o.cd_ref, o.dateobs, o.altitude_retenue, o.geojson_point, o.effectif_total, t.lb_nom, t.nom_vern\
    FROM atlas.vm_observations o\
    JOIN atlas.vm_taxons t ON t.cd_ref = o.cd_ref \
    WHERE o.cd_ref = :thiscdref AND o.insee = :thisInsee"
    observations = connection.execute(text(sql), thiscdref=cd_ref, thisInsee = insee)
    obsList=list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + ' | ' + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {'id_synthese' : o.id_synthese,
                'cd_ref': o.cd_ref,
                'dateobs': str(o.dateobs),
                'altitude_retenue' : o.altitude_retenue,
                'effectif_total' : o.effectif_total,
                'taxon': taxon,
                'geojson_point':ast.literal_eval(o.geojson_point),
                }
        obsList.append(temp)
    return obsList





def getObservers(connection, cd_ref):
    sql = "SELECT distinct observateurs \
    FROM atlas.vm_observations \
    WHERE cd_ref in ( \
    SELECT * from atlas.find_all_taxons_childs(:thiscdref) \
    )OR cd_ref = :thiscdref"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    setObs = set()
    for r in req:
        tabObs = r.observateurs.split(', ')
        for o in tabObs:
            o = o.lower()
            setObs.add(o)
    finalList = list()
    for s in setObs:
        tabInter= s.split(' ')
        fullName= str()
        i=0
        while i<len(tabInter):
            if i == len(tabInter)-1:
                fullName += tabInter[i].capitalize()
            else:
                fullName += tabInter[i].capitalize() + " "
            i=i+1              
        finalList.append(fullName)
    return sorted(finalList)




def statIndex(connection):
    result = {'nbTotalObs': None, 'nbTotalTaxons': None, 'town': None, 'photo': None}

    sql = "SELECT COUNT(*) AS count \
    FROM atlas.vm_observations "
    req = connection.execute(text(sql))
    for r in req:
        result['nbTotalObs'] = r.count

    sql = "SELECT COUNT(*) AS count\
    FROM atlas.vm_communes"
    req=connection.execute(text(sql))
    for r in req:
        result['town'] = r.count

    sql = "SELECT COUNT(DISTINCT cd_ref) AS count \
    FROM atlas.vm_taxons"
    connection.execute(text(sql))
    req=connection.execute(text(sql))
    for r in req:
        result['nbTotalTaxons'] = r.count

    sql= "SELECT COUNT (DISTINCT id_media) AS count \
    FROM atlas.vm_medias \
    WHERE id_type IN (:idType1, :id_type2)"
    req = connection.execute(text(sql), idType1 = config.ATTR_MAIN_PHOTO, id_type2=config.ATTR_OTHER_PHOTO)
    for r in req:
        result['photo']= r.count
    return result


def genericStat (connection, tab):
    tabStat = list()
    for pair in tab:
        rang, nomTaxon = pair.items()[0]
        sql= "SELECT COUNT (o.id_synthese) AS nb_obs, \
            COUNT (DISTINCT t.cd_ref) AS nb_taxons \
            FROM atlas.vm_taxons t \
            JOIN atlas.vm_observations o ON o.cd_ref = t.cd_ref \
            WHERE t."+rang+"= '"+nomTaxon+"'"
        req = connection.execute(sql)
        for r in req:
            temp = {'nb_obs': r.nb_obs, 'nb_taxons': r.nb_taxons}
            tabStat.insert(0, temp)
    return tabStat

def genericStatMedias(connection, tab):
    tabStat = list()
    for i in range(len(tab)):
        rang, nomTaxon = tab[i].items()[0]
        sql= "SELECT COUNT(o.id_synthese) as nb_obs, o.cd_ref, t.lb_nom, t.nom_vern, t.group2_inpn, m.url, m.chemin, m.auteur \
                FROM atlas.vm_observations o \
                JOIN atlas.vm_taxons t ON t.cd_ref = o.cd_ref \
                JOIN atlas.vm_medias m ON m.cd_ref = o.cd_ref \
                WHERE t."+rang+"= '"+nomTaxon+"' AND m.id_type = 1 \
                GROUP BY o.cd_ref, t.lb_nom, t.nom_vern, m.url, m.chemin, m.auteur, t.group2_inpn \
                ORDER BY nb_obs DESC \
                LIMIT 10"
        req = connection.execute(sql)
        tabStat.insert(i, list())
        for r in req:
            shorterName = r.nom_vern.split(",")
            shorterName = shorterName[0]
            temp = {'cd_ref': r.cd_ref, 'lb_nom' : r.lb_nom, 'nom_vern': shorterName, 'path': utils.findPath(r), 'author': r.auteur, 'group2_inpn': utils.deleteAccent(r.group2_inpn)}
            tabStat[i].append(temp)
    if len(tabStat[0]) == 0:
        return None
    for i in range(len(tabStat)):
        random.shuffle(tabStat[i])
    return tabStat
