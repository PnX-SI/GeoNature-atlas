#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas import APP_DIR, BASE_DIR, manage
import sys
import unicodedata
sys.path.insert(0, APP_DIR + '/modeles/entities')
sys.path.insert(0, BASE_DIR)
import config
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

def deleteAccent(string): 
    return unicodedata.normalize('NFD', string).encode('ascii', 'ignore')  


#with distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsCommunes(insee):
    req =  session.query(distinct(VmTaxons.nom_complet_html), func.count(VmObservations.id_synthese).label('count'),VmTaxons.nom_vern, VmObservations.cd_ref, func.max(VmObservations.dateobs), VmTaxons.group2_inpn)\
    .join(VmObservations, VmTaxons.cd_ref==VmObservations.cd_ref).group_by(VmTaxons.nom_complet_html, VmTaxons.nom_vern, VmObservations.cd_ref, VmTaxons.group2_inpn)\
    .order_by('count DESC').filter(VmObservations.insee== str(insee)).all()
    taxonCommunesList = list()
    nbObsTotal = 0
    for r in req:
        temp = {'nom_complet_html': r[0], 'nb_obs' : r[1], 'nom_vern': r[2], 'cd_ref': r[3], 'last_obs' : r[4], 'group2_inpn': deleteAccent(r[5]) }
        taxonCommunesList.append(temp)
        nbObsTotal = nbObsTotal+ r[1]
    return {'taxons': taxonCommunesList, 'nbObsTotal' : nbObsTotal}


def getTaxonChilds(cd_ref):
    rank = config.LIMIT_FICHE_LISTE_HIERARCHY
    sql = "select tax.nom_complet_html, \
    count(obs.id_synthese) as nb_obs, \
    tax.nom_vern, \
    max(obs.dateobs) as last_obs, \
    tax.cd_ref, \
    tax.group2_inpn \
    from atlas.vm_taxons tax \
    JOIN atlas.vm_observations obs on obs.cd_ref = tax.cd_ref \
    JOIN atlas.temp_bib_taxref_rangs bib_rang on tax.nom_rang = bib_rang.nom_rang \
    where tax.cd_ref in ( \
    select * from atlas.find_all_taxons_childs(:thiscdref) \
    ) AND (bib_rang.tri_rang <= :thisRank) \
    Group by tax.nom_complet_html, tax.nom_vern, tax.cd_ref, tax.group2_inpn".encode('UTF-8')
    req = connection.execute(text(sql), thiscdref = cd_ref, thisRank = rank)
    taxonRankList = list()
    nbObsTotal = 0
    for r in req:
        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref, 'last_obs' : r.last_obs, 'group2_inpn': deleteAccent(r.group2_inpn)}
        taxonRankList.append(temp)
        nbObsTotal = nbObsTotal+ r.nb_obs
    return {'taxons': taxonRankList, 'nbObsTotal' : nbObsTotal}
