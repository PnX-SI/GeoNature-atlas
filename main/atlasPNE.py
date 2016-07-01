#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template, jsonify
from werkzeug.wrappers import Response
import config
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, vmSearchTaxonRepository, vmMoisRepository, vmTaxrefRepository
from . import main
import json


@main.route('/' , methods=['GET', 'POST'])
def index():
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    observations = vmObservationsRepository.lastObservations(config.LIMIT_OBSERVATION)
    return render_template('index.html', listeTaxons=listeTaxons, observations=observations)

@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    listeTaxons = vmSearchTaxonRepository.listeTaxons()
    taxon = vmTaxonsRepository.rechercheEspece(cd_ref)
    observations = vmObservationsRepository.searchObservation(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudes(cd_ref)
    months = vmMoisRepository.getMonthlyObservations(cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(cd_ref)
    communes = vmObservationsRepository.getCommunes(cd_ref)
    return render_template('ficheEspece.html', taxon=taxon, listeTaxons=listeTaxons, observations=observations, cd_ref=cd_ref, altitudes=altitudes, months= months, synonyme=synonyme, communes=communes)


@main.route('/commune/<insee>')
def ficheCommune(insee):
    listeTaxons = vmObservationsRepository.getTaxonsCommunes(str(insee))
    return render_template('ficheCommune.html', listeTaxons = listeTaxons)