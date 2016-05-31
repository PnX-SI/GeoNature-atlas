#! /usr/bin/python
# -*- coding:utf-8 -*-
import os
import sys
from flask import Flask, request, render_template
from modeles.repositories.taxonsRepository import *
dirpath = os.path.abspath(os.path.dirname(__file__))
parentPath = os.path.abspath(os.path.join(dirpath, os.pardir))
templatePath = parentPath+'/templates'


app = Flask(__name__, template_folder=templatePath)
app.debug = True



@app.route('/' , methods=['GET', 'POST'])
def index():
    mot = "Une super application flask"
    return render_template('index.html', mot = mot)

@app.route('/espece', methods=['GET', 'POST'])
def ficheEspece():
    if request.method == 'POST':
        taxonFormulaire = request.form['taxon']
        taxon = rechercheEspece(taxonFormulaire)
        return render_template('ficheEspece.html', taxon=taxon)






    
    





