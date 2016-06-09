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
    listeTaxons = vmTaxonsRepository.listeTaxonsFr()
    return render_template('index.html', listeTaxons=listeTaxons)

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    listeTaxons = vmTaxonsRepository.listeTaxonsFr()
    taxonFormulaire = request.args['taxon']
    taxon = vmTaxonsRepository.rechercheEspece(taxonFormulaire)
    
    cd_ref = vmTaxonsRepository.getTaxref(taxonFormulaire)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    return render_template('ficheEspece.html', taxon=taxon, listeTaxons=listeTaxons, observations=observations, cd_ref=cd_ref)



# @main.route('/listeTaxons', methods=['GET', 'POST'])
# def taxonLatin():

#     # prem = jsonTaxon[0] # marche avec 0 mais pas avec tout le tableau d'objet
#     listeTaxons = vmTaxonsRepository.listeTaxonsFr()
#     return jsonify(result=listeTaxons)
