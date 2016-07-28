#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
import config
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, \
 vmSearchTaxonRepository, vmMoisRepository, vmTaxrefRepository, tCommunesRepository, vmObservationsMaillesRepository
from . import main
import json
APP_DIR = os.path.abspath(os.path.dirname(__file__))
BASE_DIR = os.path.abspath(os.path.join(APP_DIR, os.pardir))
sys.path.insert(0, BASE_DIR)
from atlas import manage



@main.route('/' , methods=['GET', 'POST'])
def index():
    session = manage.loadSession()

    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    observations = vmObservationsRepository.lastObservations(session, config.LIMIT_OBSERVATION)
    communesSearch = tCommunesRepository.getAllCommune(session)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'HOMEMAP': True}
    session.close()

    return render_template('index.html', listeTaxonsSearch=listeTaxonsSearch, observations=observations, communesSearch=communesSearch, configuration = configuration)


@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    session = manage.loadSession()
    connection = manage.engine.connect()

    cd_ref = int(cd_ref)
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    taxon = vmTaxrefRepository.searchEspece(connection, session, cd_ref)
    if config.AFFICHAGE_MAILLE:
        observations = {'maille' : vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref) }
    else:
        observations = {'point': vmObservationsRepository.searchObservationsChilds(connection, cd_ref), 'maille' : vmObservationsMaillesRepository.getObservationsMaillesChilds(connection, cd_ref)}
    firstObservation = vmObservationsRepository.firstObservationChild(connection, cd_ref)
    altitudes = vmAltitudesRepository.getAltitudesChilds(connection, cd_ref)
    months = vmMoisRepository.getMonthlyObservationsChilds(connection, cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(session, cd_ref)
    communes = tCommunesRepository.getCommunesObservationsChilds(connection, cd_ref)
    communesSearch = tCommunesRepository.getAllCommune(session)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(session, cd_ref)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY,\
    'AFFICHAGE_MAILLE' : config.AFFICHAGE_MAILLE, 'ZOOM_LEVEL_POINT': config.ZOOM_LEVEL_POINT, 'LIMIT_CLUSTER_POINT': config.LIMIT_CLUSTER_POINT}
    
    connection.close()
    session.close()

    return render_template('ficheEspece.html', taxon=taxon, listeTaxonsSearch=listeTaxonsSearch, observations=observations , firstObservation = firstObservation ,\
     cd_ref=cd_ref, altitudes=altitudes, months=months, synonyme=synonyme, communes=communes, communesSearch=communesSearch, taxonomyHierarchy = taxonomyHierarchy,\
      configuration=configuration)


@main.route('/commune/<insee>', methods=['GET', 'POST'])
def ficheCommune(insee):
    session = manage.loadSession()

    listTaxons = vmTaxonsRepository.getTaxonsCommunes(session, str(insee))
    commune = tCommunesRepository.getCommuneFromInsee(session, insee)
    communesSearch = tCommunesRepository.getAllCommune(session)
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    myType = 1
    configuration = {'STRUCTURE' : config.STRUCTURE}
    
    session.close()

    return render_template('listTaxons.html', myType=myType, listTaxons = listTaxons, referenciel = commune, communesSearch = communesSearch, listeTaxonsSearch = listeTaxonsSearch, configuration = configuration)


@main.route('/liste/<cd_ref>', methods=['GET', 'POST'])
def ficheRangTaxonomie(cd_ref):
    session = manage.loadSession()
    connection = manage.engine.connect()

    listTaxons = vmTaxonsRepository.getTaxonsChildsList(connection, cd_ref)
    referenciel = vmTaxrefRepository.getInfoFromCd_ref(session, cd_ref)
    communesSearch = tCommunesRepository.getAllCommune(session)
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons(session)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(session, cd_ref)
    myType = 2

    connection.close()
    session.close()

    configuration = {'STRUCTURE' : config.STRUCTURE, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY}
    return render_template('listTaxons.html',  myType=myType ,listTaxons = listTaxons, referenciel = referenciel, communesSearch = communesSearch, listeTaxonsSearch = listeTaxonsSearch, \
        taxonomyHierarchy=taxonomyHierarchy, configuration=configuration)


