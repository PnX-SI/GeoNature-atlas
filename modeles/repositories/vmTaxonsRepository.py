#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
from vmTaxons import VmTaxons
from vmObservations import VmObservations
from sqlalchemy import distinct, func
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker
from datetime import date





session = manage.loadSession()

connection = manage.engine.connect()

#recherche par espece, renvoie un tableau contenant un element: un dict contenant tous les attributs de la table
def rechercheEspece(cd_ref):
    taxonRecherche = session.query(VmTaxons).filter(VmTaxons.cd_ref == cd_ref).all()
    return taxonRecherche[0]


#with distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsCommunes(insee):
    req =  session.query(distinct(VmTaxons.nom_complet_html), func.count(VmObservations.id_synthese).label('count'),VmTaxons.nom_vern, VmObservations.cd_ref, func.max(VmObservations.dateobs))\
    .join(VmObservations, VmTaxons.cd_ref==VmObservations.cd_ref).group_by(VmTaxons.nom_complet_html, VmTaxons.nom_vern, VmObservations.cd_ref)\
    .order_by('count DESC').filter(VmObservations.insee== str(insee)).all()
    taxonCommunesList = list()
    for r in req:
        temp = {'nom_complet_html': r[0], 'nb_obs' : r[1], 'nom_vern': r[2], 'cd_ref': r[3], 'last_obs' : r[4]}
        taxonCommunesList.append(temp)
    return taxonCommunesList


def getTaxonChilds(cd_ref):
    rank = 35
    sql = "select tax.nom_complet_html, \
    count(obs.id_synthese) as nb_obs, \
    tax.nom_vern, \
    max(obs.dateobs) as last_obs, \
    tax.cd_ref \
    from atlas.vm_taxons tax \
    JOIN atlas.vm_observations obs on obs.cd_ref = tax.cd_ref \
    JOIN atlas.temp_bib_taxref_rangs bib_rang on tax.nom_rang = bib_rang.nom_rang \
    where tax.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    ) AND (bib_rang.tri_rang <= :thisRank) \
    Group by tax.nom_complet_html, tax.nom_vern, tax.cd_ref".encode('UTF-8')
    req = connection.execute(text(sql), thiscdref = cd_ref, thisRank = rank)
    taxonRankList = list()
    for r in req:
        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref, 'last_obs' : r.last_obs}
        taxonRankList.append(temp)
    return taxonRankList
