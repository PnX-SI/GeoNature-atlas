#! /usr/bin/python
# -*- coding:utf-8 -*-

import sys
sys.path.insert(0,'/home/synthese/atlas/modeles/entities')
sys.path.insert(0,'/home/synthese/atlas/config')
from databaseini import *
from taxrefBibTaxons import *
from sqlalchemy import distinct, func

session = loadSession()

#recherche par espece, renvoie un tableau contenant les caracteristiques de l'espece
def rechercheEspece(taxon):
    taxon = str(taxon)
    taxonRecherche = session.query(TaxrefBibtaxons).filter(TaxrefBibtaxons.nom_francais == taxon).all()
    return taxonRecherche[0]

def listeTaxonsLatin():
    taxons = session.query(TaxrefBibtaxons.id_taxon, TaxrefBibtaxons.nom_latin).all()
    taxonJson = dict()
    # for t in taxons: