#! /usr/bin/python
# -*- coding:utf-8 -*-

import sys
import os
sys.path.insert(0,'/home/theo/atlas/modeles/entities')
sys.path.insert(0,'/home/theo')
from atlas import manage
from taxrefBibTaxons import TaxrefBibtaxons
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker


session = manage.loadSession()

#recherche par espece, renvoie un tableau contenant les caracteristiques de l'espece
def rechercheEspece(taxon):
    taxon = str(taxon)
    #taxonRecherche = session.query(TaxrefBibtaxons).filter(TaxrefBibtaxons.nom_francais == taxon).all()
    taxonRecherche = session.query(TaxrefBibtaxons).filter(TaxrefBibtaxons.nom_francais.ilike('%'+taxon)).all()
    return taxonRecherche[0]

#revoie un json de tout les nom latin et de id_taxon
def listeTaxonsFr():
    return session.query(TaxrefBibtaxons.nom_francais).all()
    # jsonTaxon = list()
    # for t in taxons:
    #     objTaxon = {'id_taxon': t.id_taxon, 'nom_latin': t.nom_latin}
    #     jsonTaxon.append(objTaxon)
    # return jsonTaxon      


    # for t in taxons: