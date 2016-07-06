#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
import config
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, vmSearchTaxonRepository, vmMoisRepository, vmTaxrefRepository, tCommunesRepository
from . import main
import json


@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    observations = vmObservationsRepository.lastObservations(config.LIMIT_OBSERVATION)
    communesSearch = tCommunesRepository.getAllCommune()
    return render_template('index.html', listeTaxonsSearch=listeTaxonsSearch, observations=observations, communesSearch=communesSearch)

@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    cd_ref = int(cd_ref)
    listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    taxon = vmTaxonsRepository.rechercheEspece(cd_ref)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudes(cd_ref)
    months = vmMoisRepository.getMonthlyObservations(cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(cd_ref)
    communes = vmObservationsRepository.getCommunes(cd_ref)
    communesSearch = tCommunesRepository.getAllCommune()
    return render_template('ficheEspece.html', taxon=taxon, listeTaxonsSearch=listeTaxonsSearch, observations=observations, cd_ref=cd_ref, altitudes=altitudes, months= months, synonyme=synonyme, communes=communes, communesSearch=communesSearch)


@main.route('/commune/<insee>', methods=['GET', 'POST'])
def ficheCommune(insee):
    listTaxons = vmObservationsRepository.getTaxonsCommunes(str(insee))
    commune = tCommunesRepository.getCommuneFromInsee(insee)
    communesSearch = tCommunesRepository.getAllCommune()
    listeTaxonsSearch = listeTaxonsSearch = vmSearchTaxonRepository.listeTaxons()
    return render_template('listTaxons.html', listTaxons = listTaxons, referenciel = commune, communesSearch = communesSearch, listeTaxonsSearch = listeTaxonsSearch)


# @main.route('/liste/<cd_ref')
# def listTaxonomy(cd_ref):  
#     