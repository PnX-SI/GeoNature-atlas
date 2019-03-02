
# -*- coding:utf-8 -*-

from flask import render_template, redirect, abort
from configuration import config
from modeles.repositories import (
    vmTaxonsRepository, vmObservationsRepository, vmAltitudesRepository,
    vmMoisRepository, vmTaxrefRepository,
    vmCommunesRepository, vmObservationsMaillesRepository, vmMedias,
    vmCorTaxonAttribut, vmTaxonsMostView
)
from . import utils

from flask import Blueprint
main = Blueprint('main', __name__)

base_configuration = {
    'STRUCTURE': config.STRUCTURE,
    'NOM_APPLICATION': config.NOM_APPLICATION,
    'URL_APPLICATION': config.URL_APPLICATION,
    'AFFICHAGE_FOOTER': config.AFFICHAGE_FOOTER,
    'ID_GOOGLE_ANALYTICS': config.ID_GOOGLE_ANALYTICS,
    'STATIC_PAGES': config.STATIC_PAGES,
    'TAXHUB_URL': config.TAXHUB_URL if hasattr(config, 'TAXHUB_URL') else None
}


@main.route(
    '/espece/'+config.REMOTE_MEDIAS_PATH+'<image>',
    methods=['GET', 'POST']
)
def especeMedias(image):
    return redirect(config.REMOTE_MEDIAS_URL+config.REMOTE_MEDIAS_PATH+image)


@main.route(
    '/commune/'+config.REMOTE_MEDIAS_PATH+'<image>',
    methods=['GET', 'POST']
)
def communeMedias(image):
    return redirect(config.REMOTE_MEDIAS_URL+config.REMOTE_MEDIAS_PATH+image)


@main.route(
    '/liste/'+config.REMOTE_MEDIAS_PATH+'<image>',
    methods=['GET', 'POST']
)
def listeMedias(image):
    return redirect(config.REMOTE_MEDIAS_URL+config.REMOTE_MEDIAS_PATH+image)


@main.route(
    '/groupe/'+config.REMOTE_MEDIAS_PATH+'<image>',
    methods=['GET', 'POST']
)
def groupeMedias(image):
    return redirect(config.REMOTE_MEDIAS_URL+config.REMOTE_MEDIAS_PATH+image)


@main.route(
    '/'+config.REMOTE_MEDIAS_PATH+'<image>',
    methods=['GET', 'POST']
)
def indexMedias(image):
    return redirect(config.REMOTE_MEDIAS_URL+config.REMOTE_MEDIAS_PATH+image)


@main.route('/', methods=['GET', 'POST'])
def index():
    session = utils.loadSession()
    connection = utils.engine.connect()

    if config.AFFICHAGE_MAILLE:
        observations = vmObservationsMaillesRepository.lastObservationsMailles(
            connection, config.NB_DAY_LAST_OBS, config.ATTR_MAIN_PHOTO
        )
    else:
        observations = vmObservationsRepository.lastObservations(
            connection, config.NB_DAY_LAST_OBS, config.ATTR_MAIN_PHOTO
        )

    communesSearch = vmCommunesRepository.getAllCommunes(session)
    mostViewTaxon = vmTaxonsMostView.mostViewTaxon(connection)
    stat = vmObservationsRepository.statIndex(connection)
    customStat = vmObservationsRepository.genericStat(
        connection, config.RANG_STAT
    )
    customStatMedias = vmObservationsRepository.genericStatMedias(
        connection, config.RANG_STAT
    )

    configuration = base_configuration.copy()
    configuration.update({
        'HOMEMAP': True,
        'TEXT_LAST_OBS': config.TEXT_LAST_OBS,
        'AFFICHAGE_MAILLE': config.AFFICHAGE_MAILLE,
        'AFFICHAGE_DERNIERES_OBS': config.AFFICHAGE_DERNIERES_OBS,
        'AFFICHAGE_EN_CE_MOMENT': config.AFFICHAGE_EN_CE_MOMENT,
        'AFFICHAGE_STAT_GLOBALES': config.AFFICHAGE_STAT_GLOBALES,
        'AFFICHAGE_RANG_STAT': config.AFFICHAGE_RANG_STAT,
        'COLONNES_RANG_STAT': config.COLONNES_RANG_STAT,
        'RANG_STAT_FR': config.RANG_STAT_FR,
        'MAP': config.MAP,
        'AFFICHAGE_INTRODUCTION': config.AFFICHAGE_INTRODUCTION
    })

    connection.close()
    session.close()

    return render_template(
        'templates/index.html',
        observations=observations,
        communesSearch=communesSearch,
        mostViewTaxon=mostViewTaxon,
        stat=stat,
        customStat=customStat,
        customStatMedias=customStatMedias,
        configuration=configuration
    )


@main.route('/espece/<int:cd_ref>', methods=['GET', 'POST'])
def ficheEspece(cd_ref):
    session = utils.loadSession()
    connection = utils.engine.connect()

    cd_ref = int(cd_ref)
    taxon = vmTaxrefRepository.searchEspece(connection, cd_ref)
    altitudes = vmAltitudesRepository.getAltitudesChilds(connection, cd_ref)
    months = vmMoisRepository.getMonthlyObservationsChilds(connection, cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(connection, cd_ref)
    communes = vmCommunesRepository.getCommunesObservationsChilds(
        connection, cd_ref
    )
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(session, cd_ref)
    firstPhoto = vmMedias.getFirstPhoto(
        connection, cd_ref, config.ATTR_MAIN_PHOTO
    )
    photoCarousel = vmMedias.getPhotoCarousel(
        connection, cd_ref, config.ATTR_OTHER_PHOTO
    )
    videoAudio = vmMedias.getVideo_and_audio(
        connection, cd_ref, config.ATTR_AUDIO, config.ATTR_VIDEO_HEBERGEE,
        config.ATTR_YOUTUBE, config.ATTR_DAILYMOTION, config.ATTR_VIMEO
    )
    articles = vmMedias.getLinks_and_articles(
        connection, cd_ref, config.ATTR_LIEN, config.ATTR_PDF
    )
    taxonDescription = vmCorTaxonAttribut.getAttributesTaxon(
        connection, cd_ref, config.ATTR_DESC, config.ATTR_COMMENTAIRE,
        config.ATTR_MILIEU, config.ATTR_CHOROLOGIE
    )
    observers = vmObservationsRepository.getObservers(connection, cd_ref)

    configuration = base_configuration.copy()
    configuration.update({
        'LIMIT_FICHE_LISTE_HIERARCHY': config.LIMIT_FICHE_LISTE_HIERARCHY,
        'PATRIMONIALITE': config.PATRIMONIALITE,
        'PROTECTION': config.PROTECTION,
        'GLOSSAIRE': config.GLOSSAIRE,
        'AFFICHAGE_MAILLE': config.AFFICHAGE_MAILLE,
        'TYPE_MAILLE': config.TYPE_MAILLE,
        'ZOOM_LEVEL_POINT': config.ZOOM_LEVEL_POINT,
        'LIMIT_CLUSTER_POINT': config.LIMIT_CLUSTER_POINT,
        'FICHE_ESPECE': True,
        'MAP': config.MAP
    })

    connection.close()
    session.close()

    return render_template(
        'templates/ficheEspece.html',
        taxon=taxon,
        listeTaxonsSearch=[],
        observations=[],
        cd_ref=cd_ref,
        altitudes=altitudes,
        months=months,
        synonyme=synonyme,
        communes=communes,
        communesSearch=communesSearch,
        taxonomyHierarchy=taxonomyHierarchy,
        firstPhoto=firstPhoto,
        photoCarousel=photoCarousel,
        videoAudio=videoAudio,
        articles=articles,
        taxonDescription=taxonDescription,
        observers=observers,
        configuration=configuration
    )


@main.route('/commune/<insee>', methods=['GET', 'POST'])
def ficheCommune(insee):
    session = utils.loadSession()
    connection = utils.engine.connect()

    listTaxons = vmTaxonsRepository.getTaxonsCommunes(connection, insee)
    commune = vmCommunesRepository.getCommuneFromInsee(connection, insee)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    if config.AFFICHAGE_MAILLE:
        observations = vmObservationsMaillesRepository.lastObservationsCommuneMaille(
            connection, config.NB_LAST_OBS, insee
        )
    else:
        observations = vmObservationsRepository.lastObservationsCommune(
            connection, config.NB_LAST_OBS, insee
        )

    observers = vmObservationsRepository.getObserversCommunes(
        connection, insee
    )

    configuration = base_configuration.copy()
    configuration.update({
        'NB_LAST_OBS': config.NB_LAST_OBS,
        'AFFICHAGE_MAILLE': config.AFFICHAGE_MAILLE,
        'MAP': config.MAP,
        'MYTYPE': 1,
        'PATRIMONIALITE': config.PATRIMONIALITE,
        'PROTECTION': config.PROTECTION
    })

    session.close()
    connection.close()

    return render_template(
        'templates/ficheCommune.html',
        listTaxons=listTaxons,
        referenciel=commune,
        communesSearch=communesSearch,
        observations=observations,
        observers=observers,
        configuration=configuration
    )


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

    configuration = base_configuration.copy()
    configuration.update({
        'LIMIT_FICHE_LISTE_HIERARCHY': config.LIMIT_FICHE_LISTE_HIERARCHY,
        'MYTYPE': 0,
        'PATRIMONIALITE': config.PATRIMONIALITE,
        'PROTECTION': config.PROTECTION,
    })

    return render_template(
        'templates/ficheRangTaxonomique.html',
        listTaxons=listTaxons,
        referenciel=referenciel,
        communesSearch=communesSearch,
        taxonomyHierarchy=taxonomyHierarchy,
        observers=observers,
        configuration=configuration
    )


@main.route('/groupe/<groupe>', methods=['GET', 'POST'])
def ficheGroupe(groupe):
    session = utils.loadSession()
    connection = utils.engine.connect()

    groups = vmTaxonsRepository.getAllINPNgroup(connection)
    listTaxons = vmTaxonsRepository.getTaxonsGroup(connection, groupe)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    observers = vmObservationsRepository.getGroupeObservers(connection, groupe)

    session.close()
    connection.close()

    configuration = base_configuration.copy()
    configuration.update({
        'LIMIT_FICHE_LISTE_HIERARCHY': config.LIMIT_FICHE_LISTE_HIERARCHY,
        'MYTYPE': 0,
        'PATRIMONIALITE': config.PATRIMONIALITE,
        'PROTECTION': config.PROTECTION
    })

    return render_template(
        'templates/ficheGroupe.html',
        listTaxons=listTaxons,
        communesSearch=communesSearch,
        referenciel=groupe,
        groups=groups,
        observers=observers,
        configuration=configuration
    )


@main.route('/photos', methods=['GET', 'POST'])
def photos():
    session = utils.loadSession()
    connection = utils.engine.connect()

    groups = vmTaxonsRepository.getINPNgroupPhotos(connection)
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    configuration = base_configuration

    session.close()
    connection.close()
    return render_template(
        'templates/galeriePhotos.html',
        communesSearch=communesSearch,
        groups=groups,
        configuration=configuration
    )


@main.route('/<page>', methods=['GET', 'POST'])
def get_staticpages(page):
    session = utils.loadSession()
    if (page not in config.STATIC_PAGES):
        abort(404)
    static_page = config.STATIC_PAGES[page]
    communesSearch = vmCommunesRepository.getAllCommunes(session)
    configuration = base_configuration
    session.close()
    return render_template(
        static_page['template'],
        communesSearch=communesSearch,
        configuration=configuration
    )
