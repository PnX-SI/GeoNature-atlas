#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
# from modeles.repositories.taxonsRepository import *
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository
# from modeles.repositories import syntheseRepository
from . import main
import json




@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxons = vmTaxonsRepository.listeTaxons()
    return render_template('index.html', listeTaxons=listeTaxons)

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    listeTaxons = vmTaxonsRepository.listeTaxons()
    cd_ref = request.args['cd_ref']
    taxon = vmTaxonsRepository.rechercheEspece(cd_ref)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    return render_template('ficheEspece.html', taxon=taxon, listeTaxons=listeTaxons, observations=observations, cd_ref=cd_ref)
