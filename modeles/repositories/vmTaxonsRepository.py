#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmTaxons import VmTaxons
from sqlalchemy import distinct, func
from sqlalchemy.orm import sessionmaker




session = manage.loadSession()

#recherche par espece, renvoie un tableau contenant un element: un dict contenant tous les attributs de la table
def rechercheEspece(taxon):
    taxon = str(taxon)
    taxonRecherche = session.query(VmTaxons).filter(VmTaxons.lb_nom.ilike('%'+taxon)).all()
    return taxonRecherche[0]

#revoie un tableau de x dict comportant seulemen le nom latin
def listeTaxonsFr():
    return session.query(VmTaxons.lb_nom).all()


#retourne le taxref à partir du nomLatin
def getTaxref(nomLatin):
    request = session.query(VmTaxons.cd_ref).filter(VmTaxons.lb_nom.ilike('%'+nomLatin)).all()
    return request[0].cd_ref
