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


# With distinct the result in a array not an object, 0: lb_nom, 1: nom_vern
def getTaxonsCommunes(connection, insee):
    sql = """SELECT DISTINCT o.cd_ref, max(date_part('year'::text, o.dateobs)) as last_obs, COUNT(o.id_observation) AS nb_obs, t.nom_complet_html, t.nom_vern, t.group2_inpn, t.patrimonial, t.protection_stricte, m.url, m.chemin
        FROM atlas.vm_observations o
        JOIN atlas.vm_taxons t ON t.cd_ref=o.cd_ref
        LEFT JOIN atlas.vm_medias m ON m.cd_ref=o.cd_ref AND m.id_type="""+ str(config.ATTR_MAIN_PHOTO) +"""
        WHERE o.insee = :thisInsee
        GROUP BY o.cd_ref, t.nom_vern, t.nom_complet_html, t.group2_inpn, t.patrimonial, t.protection_stricte, m.url, m.chemin
        ORDER BY nb_obs DESC"""
    req = connection.execute(text(sql), thisInsee=insee)
    taxonCommunesList=list()
    nbObsTotal = 0
    for r in req:

        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref, 'last_obs' : r.last_obs, 'group2_inpn': deleteAccent(r.group2_inpn), \
        'patrimonial' : r.patrimonial, 'protection_stricte' : r.protection_stricte, 'path':utils.findPath(r) }
        taxonCommunesList.append(temp)
        nbObsTotal = nbObsTotal+ r.nb_obs
    return {'taxons': taxonCommunesList, 'nbObsTotal' : nbObsTotal}


def getTaxonsChildsList(connection, cd_ref):
    rank = config.LIMIT_FICHE_LISTE_HIERARCHY
    sql = """SELECT DISTINCT nom_complet_html, nb_obs, nom_vern, tax.cd_ref,
            yearmax, group2_inpn, patrimonial, protection_stricte, chemin, url
        FROM atlas.vm_taxons tax
        JOIN atlas.bib_taxref_rangs bib_rang on tax.id_rang= bib_rang.id_rang
        LEFT JOIN atlas.vm_medias m
        ON m.cd_ref = tax.cd_ref AND m.id_type={}
        WHERE tax.cd_ref IN (
            SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)
        ) """.format(str(config.ATTR_MAIN_PHOTO)).encode('UTF-8')
    req = connection.execute(text(sql), thiscdref=cd_ref)
    taxonRankList = list()
    nbObsTotal = 0
    for r in req:
        temp = {
            'nom_complet_html': r.nom_complet_html,
            'nb_obs': r.nb_obs,
            'nom_vern': r.nom_vern,
            'cd_ref': r.cd_ref,
            'last_obs': r.yearmax,
            'group2_inpn': deleteAccent(r.group2_inpn),
            'patrimonial': r.patrimonial,
            'protection_stricte': r.protection_stricte,
            'path': utils.findPath(r)
        }
        taxonRankList.append(temp)
        nbObsTotal = nbObsTotal + r.nb_obs
    return {'taxons': taxonRankList, 'nbObsTotal': nbObsTotal}

# Get list of INPN groups with at least one photo
def getINPNgroupPhotos(connection):
    sql=""" SELECT DISTINCT count(*) AS nb_photos, group2_inpn FROM atlas.vm_taxons T
    JOIN atlas.vm_medias M on M.cd_ref = T.cd_ref
    GROUP BY group2_inpn
    ORDER BY nb_photos DESC """
    req = connection.execute(text(sql))
    groupList = list()
    for r in req:
        temp={'group':utils.deleteAccent(r.group2_inpn), 'groupAccent': r.group2_inpn}
        groupList.append(temp)
    return groupList


def getTaxonsGroup(connection, groupe):
    sql=""" SELECT t.cd_ref, t.nom_complet_html, t.nom_vern, t.nb_obs, t.group2_inpn, t.protection_stricte, t.patrimonial, t.yearmax, m.chemin, m.url, t.nb_obs
            FROM atlas.vm_taxons t
            LEFT JOIN atlas.vm_medias m ON m.cd_ref = t.cd_ref AND m.id_type="""+ str(config.ATTR_MAIN_PHOTO) +"""
            WHERE t.group2_inpn = :thisGroupe
            GROUP BY t.cd_ref, t.nom_complet_html, t.nom_vern, t.nb_obs, t.group2_inpn, t.protection_stricte, t.patrimonial, t.yearmax, m.chemin, m.url """
    req = connection.execute(text(sql), thisGroupe = groupe)
    tabTaxons = list()
    nbObsTotal=0
    for r in req:
        nbObsTotal=nbObsTotal+r.nb_obs
        temp = {'nom_complet_html': r.nom_complet_html, 'nb_obs' : r.nb_obs, 'nom_vern': r.nom_vern, 'cd_ref': r.cd_ref,\
         'last_obs' : r.yearmax, 'group2_inpn': deleteAccent(r.group2_inpn), 'patrimonial' : r.patrimonial, 'protection_stricte' : r.protection_stricte, 'path': utils.findPath(r)}
        tabTaxons.append(temp)
    return {'taxons':tabTaxons, 'nbObsTotal': nbObsTotal}


#get all groupINPN
def getAllINPNgroup(connection):
    sql=""" SELECT SUM(nb_obs) AS som_obs, group2_inpn from atlas.vm_taxons
        GROUP BY group2_inpn
        ORDER by som_obs DESC """
    req = connection.execute(text(sql))
    groupList = list()
    for r in req:
        temp={'group':utils.deleteAccent(r.group2_inpn), 'groupAccent': r.group2_inpn}
        groupList.append(temp)
    return groupList
