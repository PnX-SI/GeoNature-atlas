#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmObservations import VmObservations
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker
import ast

session = manage.loadSession()


def searchObservation(cd_ref):
    request = session.query(VmObservations.geojson_point, VmObservations.id_synthese ).filter(VmObservations.cd_ref == cd_ref).all()
    geojson = {'type': 'FeatureCollection',
    		   'features' : list(),
    		  }
    for r in request:
        geometry = ast.literal_eval(r.geojson_point)
        properties = {'id_synthese' : r.id_synthese}
        feature = {
            'type' : 'Feature',
            'properties' : properties,
            'geometry' : geometry
        }

        geojson['features'].append(feature)

    return geojson
         



