#! /usr/bin/python
# -*- coding:utf-8 -*-
import sys
import unicodedata

from ...configuration import config
from ..entities.vmTaxons import VmTaxons
from ..entities.vmObservations import VmObservations
from sqlalchemy import distinct, func
from sqlalchemy.sql import text
from sqlalchemy.orm import sessionmaker
from datetime import date
from .. import utils



def deleteAccent(string): 
    return unicodedata.normalize('NFD', string).encode('ascii', 'ignore')  


#with distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsCommunes(connection, insee):
    sql = """SELECT DISTINCT o.cd_ref, MAX(o.dateobs) as last_obs, COUNT(o.id_synthese) AS nb_obs, t.nom_complet_html, t.nom_vern, t.group2_inpn, t.patrimonial, t.protection_stricte, m.url, m.chemin
        FROM atlas.vm_observations o
        JOIN atlas.vm_taxons t ON t.cd_ref=o.cd_ref
        LEFT JOIN atlas.vm_medias m ON m.cd_ref=o.cd_ref AND m.id_type=1
        WHERE o.insee = :thisInsee
        GROUP BY o.cd_ref, t.nom_vern, t.nom_complet_html, t.group2_inpn, t.patrimonial, t.protection_stricte, m.url, m.chemin
        ORDER BY nb_obs DESC"""
    req = connection.execute(text(sql), thisInsee=insee)
    taxonCommunesList=list()
    nbObsTotal = 0
    for r in req:

        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref, 'last_obs' : str(r.last_obs), 'group2_inpn': deleteAccent(r.group2_inpn), \
        'patrimonial' : r.patrimonial, 'protection_stricte' : r.protection_stricte, 'path':utils.findPath(r) }
        taxonCommunesList.append(temp)
        nbObsTotal = nbObsTotal+ r.nb_obs
    return {'taxons': taxonCommunesList, 'nbObsTotal' : nbObsTotal}


def getTaxonsChildsList(connection, cd_ref):
    rank = config.LIMIT_FICHE_LISTE_HIERARCHY
    sql = """SELECT tax.nom_complet_html, 
    count(obs.id_synthese) as nb_obs, 
    tax.nom_vern, 
    max(obs.dateobs) as last_obs, 
    tax.cd_ref, 
    tax.group2_inpn, 
    tax.patrimonial, 
    tax.protection_stricte,
    m.url,
    m.chemin
    FROM atlas.vm_taxons tax 
    JOIN atlas.vm_observations obs on obs.cd_ref = tax.cd_ref 
    JOIN atlas.bib_taxref_rangs bib_rang on tax.nom_rang = bib_rang.nom_rang
    LEFT JOIN atlas.vm_medias m ON m.cd_ref = tax.cd_ref AND m.id_type=1 
    where tax.cd_ref in ( select * from atlas.find_all_taxons_childs(:thiscdref) 
    ) AND (bib_rang.tri_rang >= :thisRank) 
    Group by tax.nom_complet_html, tax.nom_vern, tax.cd_ref, tax.group2_inpn, tax.patrimonial, tax.protection_stricte, m.url, m.chemin""".encode('UTF-8')
    req = connection.execute(text(sql), thiscdref = cd_ref, thisRank = rank)
    taxonRankList = list()
    nbObsTotal = 0
    for r in req:
        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref,\
         'last_obs' : r.last_obs, 'group2_inpn': deleteAccent(r.group2_inpn), 'patrimonial' : r.patrimonial, 'protection_stricte' : r.protection_stricte, 'path': utils.findPath(r)}
        taxonRankList.append(temp)
        nbObsTotal = nbObsTotal+ r.nb_obs
    return {'taxons': taxonRankList, 'nbObsTotal' : nbObsTotal}

def getINPNgroup(connection):
    sql=""" SELECT DISTINCT group2_inpn FROM atlas.vm_taxons """
    req = connection.execute(text(sql))
    groupList = list()
    for r in req:
        temp={'group':utils.deleteAccent(r.group2_inpn), 'groupAccent': r.group2_inpn}
        groupList.append(temp)
    return groupList
    



