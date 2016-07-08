#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmTaxons import VmTaxons
from sqlalchemy import distinct, func
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker




session = manage.loadSession()

connection = manage.engine.connect()

#recherche par espece, renvoie un tableau contenant un element: un dict contenant tous les attributs de la table
def rechercheEspece(cd_ref):
    taxonRecherche = session.query(VmTaxons).filter(VmTaxons.cd_ref == cd_ref).all()
    return taxonRecherche[0]

def getNameFromCd_ref(cd_ref):
    session.query(VmTaxons.lb_nom).filter(VmTaxons.cd_ref == cd_ref)

def getTaxonChilds(cd_ref):
    filter1 = u"Espèce".encode('UTF-8')
    filter2 = u"Sous-espèce".encode('UTF-8')
    filter3 = u"Variété".encode('UTF-8')
    sql = "select tax.nom_complet_html, \
    count(obs.id_synthese) as nb_obs, \
    tax.nom_vern, \
    tax.cd_ref \
    from atlas.vm_taxons tax \
    JOIN atlas.vm_observations obs on obs.cd_ref = tax.cd_ref \
    where tax.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    ) AND (tax.nom_rang = :filter1 OR tax.nom_rang = :filter2 OR tax.nom_rang = :filter3) \
    Group by tax.nom_complet_html, tax.nom_vern, tax.cd_ref".encode('UTF-8')
    req = connection.execute(text(sql), thiscdref = cd_ref, filter1= filter1, filter2 = filter2, filter3=filter3)
    taxonRankList = list()
    for r in req:
        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref}
        taxonRankList.append(temp)
    return taxonRankList
