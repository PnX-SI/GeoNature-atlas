#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template
from modeles.repositories.taxonsRepository import *
from . import main



@main.route('/' , methods=['GET', 'POST'])
def index():
    mot = "Une super application flask"
    return render_template('index.html', mot = mot)

@main.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    if request.method == 'POST':
        taxonFormulaire = request.form['taxon']
        taxon = rechercheEspece(taxonFormulaire)
        return render_template('ficheEspece.html', taxon=taxon)




