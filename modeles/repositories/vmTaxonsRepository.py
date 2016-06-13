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
def rechercheEspece(cd_ref):
    taxonRecherche = session.query(VmTaxons).filter(VmTaxons.cd_ref == cd_ref).all()
    return taxonRecherche[0]

#revoie un objet de x tableaux associatifs: 0=nom_latin, 1= cd_ref
def listeTaxons():
    return session.query(VmTaxons.lb_nom, VmTaxons.cd_ref, VmTaxons.nom_vern).all()

