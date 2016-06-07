#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import appDir, baseDir, manage
import sys
sys.path.insert(0, appDir + '/modeles/entities')
sys.path.insert(0, baseDir)
from taxrefBibTaxons import TaxrefBibtaxons
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker




session = manage.loadSession()

#recherche par espece, renvoie un tableau contenant les caracteristiques de l'espece
def rechercheEspece(taxon):
    taxon = str(taxon)
    taxonRecherche = session.query(TaxrefBibtaxons).filter(TaxrefBibtaxons.nom_francais.ilike('%'+taxon)).all()
    return taxonRecherche[0]

#revoie la liste de tous les noms francais
def listeTaxonsFr():
    return session.query(TaxrefBibtaxons.nom_francais).all()
