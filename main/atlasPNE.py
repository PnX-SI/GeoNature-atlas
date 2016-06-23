#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, vmSearchTaxonRepository, vmMoisRepository, vmTaxrefRepository
from . import main
import json




@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    observations = vmObservationsRepository.lastObservations(100)
    return render_template('index.html', listeTaxons=listeTaxons, observations=observations)

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    cd_ref = request.args['cd_ref']
    taxon = vmTaxonsRepository.rechercheEspece(cd_ref)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudes(cd_ref)
    months = vmMoisRepository.getMonthlyObservations(cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(cd_ref)

    return render_template('ficheEspece.html', taxon=taxon, listeTaxons=listeTaxons, observations=observations, cd_ref=cd_ref, altitudes=altitudes, months= months, synonyme=synonyme)
