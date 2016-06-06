#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
# from modeles.repositories.taxonsRepository import *
from modeles.repositories import taxonsRepository
from . import main
import json




@main.route('/' , methods=['GET', 'POST'])
def index():
    return render_template('index.html')

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    if request.method == 'POST':
        taxonFormulaire = request.form['taxon']
        taxon = taxonsRepository.rechercheEspece(taxonFormulaire)
        return render_template('ficheEspece.html', taxon=taxon)

@main.route('/listeTaxons', methods=['GET', 'POST'])
def taxonLatin():

    # prem = jsonTaxon[0] # marche avec 0 mais pas avec tout le tableau d'objet
    listeTaxons = taxonsRepository.listeTaxonsFr()
    return jsonify(result=listeTaxons)





