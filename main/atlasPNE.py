#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, vmSearchTaxonRepository
from . import main
import json




@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    return render_template('index.html', listeTaxons=listeTaxons)

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    cd_ref = request.args['cd_ref']
    taxon = vmTaxonsRepository.rechercheEspece(cd_ref)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudes(cd_ref)
    return render_template('ficheEspece.html', taxon=taxon, listeTaxons=listeTaxons, observations=observations, cd_ref=cd_ref, altitudes=altitudes)
