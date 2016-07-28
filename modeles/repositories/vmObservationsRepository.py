#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmObservations import VmObservations
from tCommunes import LCommune
from vmTaxref import VmTaxref
from vmTaxons import VmTaxons
import tCommunesRepository
from sqlalchemy import distinct, func, extract, desc
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker
import ast
from datetime import datetime


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
        temp = {'id_synthese': o.id_synthese, 'geojson_point':ast.literal_eval(o.geojson_point), 'cd_ref': o.cd_ref, 'dateobs': str(o.dateobs), 'observateurs':o.observateurs, 'altitude_retenue': o.altitude_retenue,
               'effectif_total': o.effectif_total, 'year': o.dateobs.year}
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

    
def lastObservations(session, mylimit):
    observations = session.query(VmObservations, VmObservations.geojson_point, VmTaxref, LCommune.commune_maj)\
    .join(VmTaxref, VmObservations.cd_ref==VmTaxref.cd_nom)\
    .join(LCommune, VmObservations.insee == LCommune.insee) \
    .order_by(desc(VmObservations.dateobs)).limit(mylimit).all()
    obsList=list()
    for o in observations:
        if o.VmTaxref.nom_vern:
            taxon = o.VmTaxref.nom_vern + ' | ' + o.VmTaxref.lb_nom
        else:
            taxon = o.VmTaxref.lb_nom
        temp = {'id_synthese' : o.VmObservations.id_synthese,
                'cd_ref': o.VmObservations.cd_ref,
                'dateobs': str(o.VmObservations.dateobs),
                'altitude_retenue' : o.VmObservations.altitude_retenue,
                'effectif_total' : o.VmObservations.effectif_total,
                'taxon': taxon,
                'geojson_point':ast.literal_eval(o.geojson_point),
                'commune': o.commune_maj
                }
        obsList.append(temp)
    return obsList
      

                    