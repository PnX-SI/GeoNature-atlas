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


@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    observations = vmObservationsRepository.lastObservations(config.LIMIT_OBSERVATION)
    communesSearch = tCommunesRepository.getAllCommune()
    configuration = {'STRUCTURE' : config.STRUCTURE, 'HOMEMAP': True}
    return render_template('index.html', listeTaxonsSearch=listeTaxonsSearch, observations=observations, communesSearch=communesSearch, configuration = configuration)


@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    cd_ref = int(cd_ref)
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    taxon = vmTaxrefRepository.searchEspece(cd_ref)
    if config.AFFICHAGE_MAILLE:
        observations = {'maille' : vmObservationsMaillesRepository.getObservationsMaillesChilds(cd_ref) }
    else:
        observations = {'point': vmObservationsRepository.searchObservationsChilds(cd_ref), 'maille' : vmObservationsMaillesRepository.getObservationsMaillesChilds(cd_ref)}
    firstObservation = vmObservationsRepository.firstObservationChild(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudesChilds(cd_ref)
    months = vmMoisRepository.getMonthlyObservationsChilds(cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(cd_ref)
    communes = tCommunesRepository.getCommunesObservationsChilds(cd_ref)
    communesSearch = tCommunesRepository.getAllCommune()
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(cd_ref)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY,\
    'AFFICHAGE_MAILLE' : config.AFFICHAGE_MAILLE, 'ZOOM_LEVEL_POINT': config.ZOOM_LEVEL_POINT}
    return render_template('ficheEspece.html', taxon=taxon, listeTaxonsSearch=listeTaxonsSearch, observations=observations , firstObservation = firstObservation ,\
     cd_ref=cd_ref, altitudes=altitudes, months=months, synonyme=synonyme, communes=communes, communesSearch=communesSearch, taxonomyHierarchy = taxonomyHierarchy,\
      configuration=configuration)


@main.route('/commune/<insee>', methods=['GET', 'POST'])
def ficheCommune(insee):
    listTaxons = vmTaxonsRepository.getTaxonsCommunes(str(insee))
    commune = tCommunesRepository.getCommuneFromInsee(insee)
    communesSearch = tCommunesRepository.getAllCommune()
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    myType = 1
    configuration = {'STRUCTURE' : config.STRUCTURE}
    return render_template('listTaxons.html', myType=myType, listTaxons = listTaxons, referenciel = commune, communesSearch = communesSearch, listeTaxonsSearch = listeTaxonsSearch, configuration = configuration)


@main.route('/liste/<cd_ref>', methods=['GET', 'POST'])
def ficheRangTaxonomie(cd_ref):
    listTaxons = vmTaxonsRepository.getTaxonsChildsList(cd_ref)
    referenciel = vmTaxrefRepository.getInfoFromCd_ref(cd_ref)
    communesSearch = tCommunesRepository.getAllCommune()
    listeTaxonsSearch = listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(cd_ref)
    myType = 2
    configuration = {'STRUCTURE' : config.STRUCTURE, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY}
    return render_template('listTaxons.html',  myType=myType ,listTaxons = listTaxons, referenciel = referenciel, communesSearch = communesSearch, listeTaxonsSearch = listeTaxonsSearch, \
        taxonomyHierarchy=taxonomyHierarchy, configuration=configuration)


