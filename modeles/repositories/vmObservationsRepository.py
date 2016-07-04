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
from sqlalchemy import distinct, func, extract, desc
from sqlalchemy.orm import sessionmaker
import ast
from datetime import datetime

session = manage.loadSession()

currentYear = datetime.now().year

def toGeoJsonTaxon(queryResult, nbYear):
    geojson = {'type': 'FeatureCollection',
           'features' : list()
          }
    for r in queryResult:
        geometry = ast.literal_eval(r.geojson_point)
        properties = {'id_synthese' : r.id_synthese,
                      'cd_ref': r.cd_ref,
                      'dateobs': str(r.dateobs),
                      'observateurs' : r.observateurs,
                      'altitude_retenue' : r.altitude_retenue,
                      'effectif_total' : r.effectif_total,
                      'year': r.dateobs.year
                      }
        feature = {
            'type' : 'Feature',
            'properties' : properties,
            'geometry' : geometry
        }

        geojson['features'].append(feature)

    return geojson

def toGeoJsonHome(queryResult):
    geojson = {'type': 'FeatureCollection',
           'features' : list()
          }
    for r in queryResult:
        geometry = ast.literal_eval(r.VmObservations.geojson_point)
        # test if nom_vern not is null because 'none' isn't supported for concat
        if r.VmTaxref.nom_vern:
            taxon = r.VmTaxref.nom_vern + ' | ' + r.VmTaxref.lb_nom
        else:
            taxon = r.VmTaxref.lb_nom
        properties = {'id_synthese' : r.VmObservations.id_synthese,
                      'cd_ref': r.VmObservations.cd_ref,
                      'dateobs': str(r.VmObservations.dateobs),
                      'altitude_retenue' : r.VmObservations.altitude_retenue,
                      'effectif_total' : r.VmObservations.effectif_total,
                      'year': r.VmObservations.dateobs.year,
                      'taxon': taxon
                      }
        feature = {
            'type' : 'Feature',
            'properties' : properties,
            'geometry' : geometry
        }

        geojson['features'].append(feature)

    return geojson


def searchObservation(cd_ref):
    observations = session.query(VmObservations).filter(VmObservations.cd_ref == cd_ref).all()
    return  toGeoJsonTaxon(observations, 15)
    
def lastObservations(mylimit):
    observations = session.query(VmObservations,VmTaxref).join(VmTaxref, VmObservations.cd_ref==VmTaxref.cd_nom).order_by(desc(VmObservations.dateobs)).limit(mylimit).all()
    return  toGeoJsonHome(observations)


def getCommunes(cd_ref):
    return session.query(distinct(VmObservations.insee), VmObservations.insee,LCommune.commune_min, LCommune.commune_maj).join(LCommune, VmObservations.insee == LCommune.insee).group_by(VmObservations.insee, LCommune.commune_min, LCommune.commune_maj).filter(VmObservations.cd_ref==cd_ref).all()

#with distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsCommunes(insee):
    return session.query(distinct(VmTaxons.lb_nom), func.count(VmObservations.id_synthese).label('count'),VmTaxons.nom_vern, VmObservations.cd_ref)\
    .join(VmObservations, VmTaxons.cd_ref==VmObservations.cd_ref).group_by(VmTaxons.lb_nom, VmTaxons.nom_vern, VmObservations.cd_ref)\
    .order_by('count DESC').filter(VmObservations.insee== str(insee)).all()