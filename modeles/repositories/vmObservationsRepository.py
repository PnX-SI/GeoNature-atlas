#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmObservations import VmObservations
from sqlalchemy import distinct, func, extract
from sqlalchemy.orm import sessionmaker
import ast
from datetime import datetime

session = manage.loadSession()

currentYear = datetime.now().year

def toGeoJson(queryResult, nbYear):
    geojson = {'type': 'FeatureCollection',
           'features' : list(),
          }
    for r in queryResult:
        ageobs =  0 if (r.dateobs.year < currentYear-nbYear) else 1;
        geometry = ast.literal_eval(r.geojson_point)
        properties = {'id_synthese' : r.id_synthese,
                      'cd_ref': r.cd_ref,
                      'dateobs': str(r.dateobs),
                      'observateurs' : r.observateurs,
                      'altitude_retenue' : r.altitude_retenue,
                      'effectif_total' : r.effectif_total,
                      'ageobs': ageobs
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
    return  toGeoJson(observations, 15)
    
   

         


