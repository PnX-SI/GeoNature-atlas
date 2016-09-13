#! /usr/bin/python
# -*- coding:utf-8 -*-

from flask import Flask, request, render_template, jsonify
from configuration import config
from modeles.repositories import vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository, \
 vmSearchTaxonRepository, vmMoisRepository, vmTaxrefRepository, vmCommunesRepository, vmObservationsMaillesRepository, vmMedias, vmCorTaxonAttribut, \
 vmTaxonsMostView
import json
from . import utils

from flask import Blueprint
main = Blueprint('main', __name__)



@main.route('/' , methods=['GET', 'POST'])
def index():
    session = utils.loadSession()
    connection = utils.engine.connect()
    if config.AFFICHAGE_MAILLE:
        observations = vmObservationsMaillesRepository.lastObservationsMailles(connection, config.NB_LAST_OBS, config.ATTR_MAIN_PHOTO)
    else:
        observations = vmObservationsRepository.lastObservations(connection, config.NB_LAST_OBS, config.ATTR_MAIN_PHOTO)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    mostViewTaxon = vmTaxonsMostView.mostViewTaxon(connection)
    stat = vmObservationsRepository.statIndex(connection)
    customStat = vmObservationsRepository.genericStat(connection, config.RANG_STAT)
    customStatMedias = vmObservationsRepository.genericStatMedias(connection, config.RANG_STAT)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'NOM_APPLICATION' : config.NOM_APPLICATION, 'HOMEMAP': True, 'NB_LAST_OBS': config.NB_LAST_OBS, 'AFFICHAGE_MAILLE': config.AFFICHAGE_MAILLE, \
    'URL_PHOTO': config.URL_MEDIAS, 'RANG_STAT_FR': config.RANG_STAT_FR, 'MAP': config.MAP, 'URL_APPLICATION': config.URL_APPLICATION, 'AFFICHAGE_INTRODUCTION': config.AFFICHAGE_INTRODUCTION, \
    'AFFICHAGE_FOOTER': config.AFFICHAGE_FOOTER}
    
    connection.close()
    session.close()

    return render_template('templates/index.html', observations=observations, communesSearch=communesSearch, \
     mostViewTaxon=mostViewTaxon, stat=stat, customStat = customStat, customStatMedias=customStatMedias, configuration = configuration)


@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    session = utils.loadSession()
    connection = utils.engine.connect()

    cd_ref = int(cd_ref)
    taxon = vmTaxrefRepository.searchEspece(connection, cd_ref)
    altitudes = vmAltitudesRepository.getAltitudesChilds(connection, cd_ref)
    months = vmMoisRepository.getMonthlyObservationsChilds(connection, cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(connection, cd_ref)
    communes = vmCommunesRepository.getCommunesObservationsChilds(connection, cd_ref)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(session, cd_ref)
    firstPhoto = vmMedias.getFirstPhoto(connection, cd_ref)
    photoCarousel = vmMedias.getPhotoCarousel(connection, cd_ref)
    videoAudio = vmMedias.getVideo_and_audio(connection, cd_ref)
    articles = vmMedias.getLinks_and_articles(connection, cd_ref)
    taxonDescritpion = vmCorTaxonAttribut.getAttributesTaxon(connection, cd_ref, config.ATTR_DESC, config.ATTR_COMMENTAIRE, config.ATTR_MILIEU, config.ATTR_CORROLOGIE)
    observers = vmObservationsRepository.getObservers(connection, cd_ref)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'NOM_APPLICATION' : config.NOM_APPLICATION, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY,\
    'AFFICHAGE_MAILLE' : config.AFFICHAGE_MAILLE, 'ZOOM_LEVEL_POINT': config.ZOOM_LEVEL_POINT, 'LIMIT_CLUSTER_POINT': config.LIMIT_CLUSTER_POINT, 'FICHE_ESPECE': True, \
    'URL_PHOTO': config.URL_MEDIAS, 'MAP': config.MAP, 'URL_APPLICATION': config.URL_APPLICATION, 'AFFICHAGE_FOOTER': config.AFFICHAGE_FOOTER}
    
    connection.close()
    session.close()

    return render_template('templates/ficheEspece.html', taxon=taxon, listeTaxonsSearch=[], observations=[],\
     cd_ref=cd_ref, altitudes=altitudes, months=months, synonyme=synonyme, communes=communes, communesSearch=communesSearch, taxonomyHierarchy = taxonomyHierarchy,\
      firstPhoto= firstPhoto, photoCarousel=photoCarousel, videoAudio=videoAudio, articles=articles, taxonDescritpion=taxonDescritpion, observers=observers, \
      configuration=configuration)


@main.route('/commune/<insee>', methods=['GET', 'POST'])
def ficheCommune(insee):
    session = utils.loadSession()
    connection = utils.engine.connect()

    listTaxons = vmTaxonsRepository.getTaxonsCommunes(session, str(insee))
    commune = vmCommunesRepository.getCommuneFromInsee(connection, insee)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    if config.AFFICHAGE_MAILLE:
        observations = vmObservationsMaillesRepository.lastObservationsCommuneMaille(connection, config.NB_LAST_OBS, insee)
    else:
        observations = vmObservationsRepository.lastObservationsCommune(connection, config.NB_LAST_OBS, insee)

    observers = vmObservationsRepository.getObserversCommunes(connection, insee)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'NOM_APPLICATION' : config.NOM_APPLICATION, 'NB_LAST_OBS' : config.NB_LAST_OBS, 'AFFICHAGE_MAILLE': config.AFFICHAGE_MAILLE, 'MAP': config.MAP, \
    'URL_APPLICATION': config.URL_APPLICATION, 'MYTYPE' : 1, 'PATRIMONIALITE': config.PATRIMONIALITE, 'PROTECTION': config.PROTECTION, 'AFFICHAGE_FOOTER': config.AFFICHAGE_FOOTER}
    

    session.close()
    connection.close()

    return render_template('templates/ficheCommune.html', listTaxons = listTaxons, referenciel = commune, communesSearch = communesSearch, observations = observations, \
    observers=observers, configuration = configuration)


@main.route('/liste/<cd_ref>', methods=['GET', 'POST'])
def ficheRangTaxonomie(cd_ref):
    session = utils.loadSession()
    connection = utils.engine.connect()

    listTaxons = vmTaxonsRepository.getTaxonsChildsList(connection, cd_ref)
    referenciel = vmTaxrefRepository.getInfoFromCd_ref(session, cd_ref)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(session, cd_ref)
    observers = vmObservationsRepository.getObservers(connection, cd_ref)
    

    connection.close()
    session.close()

    configuration = {'STRUCTURE' : config.STRUCTURE, 'NOM_APPLICATION' : config.NOM_APPLICATION, 'LIMIT_FICHE_LISTE_HIERARCHY' : config.LIMIT_FICHE_LISTE_HIERARCHY,\
     'URL_APPLICATION': config.URL_APPLICATION, 'PATRIMONIALITE': config.PATRIMONIALITE, 'PROTECTION': config.PROTECTION, 'AFFICHAGE_FOOTER': config.AFFICHAGE_FOOTER}
    return render_template('templates/ficheRangTaxonomique.html', listTaxons = listTaxons, referenciel = referenciel, communesSearch = communesSearch,\
        taxonomyHierarchy=taxonomyHierarchy, observers=observers, configuration=configuration)

@main.route('/developpement', methods=['GET', 'POST'])
def developpement():
    session = utils.loadSession()

    communesSearch = vmCommunesRepository.getAllCommunes(session)
    configuration = {'STRUCTURE' : config.STRUCTURE, 'NOM_APPLICATION' : config.NOM_APPLICATION, 'URL_APPLICATION': config.URL_APPLICATION}

    session.close()
    return render_template('templates/developpement.html', communesSearch = communesSearch, configuration=configuration)