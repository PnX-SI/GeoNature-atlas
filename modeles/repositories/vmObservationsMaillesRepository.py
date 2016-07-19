#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import manage 
from modeles import utils
from sqlalchemy.sql import text
import ast

session = manage.loadSession()
connection = manage.engine.connect()

tableObservationsMailles = utils.GenericTable('atlas.vm_observations_mailles', 'atlas')
geoJson = tableObservationsMailles.tableDef.columns['geojson_maille']



def toGeoJson(queryResult):
    geojson = {'type': 'FeatureCollection',
           'features' : list()
          }
    for r in queryResult:
        geometry = ast.literal_eval(r.geojson_maille)
        properties = {'nb_observations': int(r.nb_observations)}
        feature = {
            'type' : 'Feature',
            'properties' : properties,
            'geometry' : geometry
        }

        geojson['features'].append(feature)

    return geojson


def getObservationsMaillesChilds(cd_ref):
    sql = "select distinct(obs.id_maille), \
    obs.geojson_maille, \
    sum(obs.nb_observations) as nb_observations \
    from atlas.vm_observations_mailles obs \
    where obs.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(192137)) \
    OR obs.cd_ref = 192137 \
    GROUP BY obs.geojson_maille, obs.nb_observations, obs.id_maille"
    observations = connection.execute(text(sql), thiscdref = cd_ref)
    return toGeoJson(observations)