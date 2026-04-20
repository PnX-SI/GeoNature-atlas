# -*- coding:utf-8 -*-
from urllib.parse import urlparse
from urllib.parse import urlunparse

from datetime import datetime, timedelta

from flask import Blueprint, g
from flask import (
    render_template,
    redirect,
    abort,
    current_app,
    make_response,
    request,
    url_for,
    session,
    request,
)
from flask_babel import gettext

from werkzeug.datastructures import MultiDict

from atlas.env import db
from atlas.modeles.entities import vmTaxons, vmAreas
from atlas.modeles.repositories import (
    vmOrganismsRepository,
    vmTaxonsRepository,
    vmObservationsRepository,
    vmAltitudesRepository,
    vmMoisRepository,
    vmTaxrefRepository,
    vmAreasRepository,
    vmObservationsMaillesRepository,
    vmMedias,
    vmCorTaxonAttribut,
    vmTaxonsMostView,
    vmCorTaxonOrganismRepository,
    vmStatutBdcRepository,
    corSensitivityAreaRepository,
)
from atlas.configuration.config_parser import config


main = Blueprint("main", __name__)


@main.before_request
def redirect_default_language():
    if not current_app.config["MULTILINGUAL"]:
        return

    # if lang_code already in args, do not redirect
    if "lang_code" in (request.view_args or {}):
        return

    endpoint = request.endpoint
    if endpoint and "." in endpoint:
        endpoint_with_lang = f"main.{endpoint.split('.')[1]}"
        args = request.view_args.copy() if request.view_args else {}
        args["lang_code"] = g.lang_code
        target_url = url_for(endpoint_with_lang, **args, _external=True)

        if request.url != target_url:
            return redirect(target_url)


# Activating organisms sheets routes
if config["ORGANISM_MODULE"]:

    @main.route("/organism/<int:id_organism>", methods=["GET", "POST"])
    def ficheOrganism(id_organism):

        infos_organism = vmOrganismsRepository.statOrganism(id_organism)

        stat = vmObservationsRepository.statIndex()

        mostObsTaxs = vmOrganismsRepository.topObsOrganism(id_organism)
        update_most_obs_taxons = []
        for taxon in mostObsTaxs:
            taxon_info = vmTaxrefRepository.searchEspece(taxon["cd_ref"])
            photo = vmMedias.getFirstPhoto(taxon["cd_ref"], current_app.config["ATTR_MAIN_PHOTO"])
            taxon = {**taxon, **taxon_info["taxonSearch"]}
            taxon["photo"] = photo
            update_most_obs_taxons.append(taxon)
        stats_group = vmOrganismsRepository.getTaxonRepartitionOrganism(id_organism)

        return render_template(
            "templates/organismSheet/_main.html",
            nom_organism=infos_organism["nom_organism"],
            adresse_organism=infos_organism["adresse_organism"],
            cp_organism=infos_organism["cp_organism"],
            ville_organism=infos_organism["ville_organism"],
            tel_organism=infos_organism["tel_organism"],
            url_organism=infos_organism["url_organism"],
            url_logo=infos_organism["url_logo"],
            email_organism=infos_organism["email_organism"],
            nb_taxons=infos_organism["nb_taxons"],
            nb_obs=infos_organism["nb_obs"],
            stat=stat,
            mostObsTaxs=update_most_obs_taxons,
            stats_group=stats_group,
        )


@main.route("/", methods=["GET", "POST"])
def index():

    nb_taxons = None
    listTaxons = []
    if current_app.config["AFFICHAGE_TERRITOIRE_OBS"]:
        nb_taxons = vmTaxonsRepository.get_nb_taxons()
        listTaxons = vmTaxonsRepository.getListTaxon(params=MultiDict({"page": 0}))

    # si AFFICHAGE_TERRITOIRE_OBS on charge les données en AJAX
    # si AFFICHAGE_DERNIERES_OBS = False, on ne charge pas les obs
    if (
        current_app.config["AFFICHAGE_TERRITOIRE_OBS"]
        or not current_app.config["AFFICHAGE_DERNIERES_OBS"]
    ):
        observations = []
    observations_mailles = None
    if current_app.config["AFFICHAGE_DERNIERES_OBS"]:
        # on charge les observations point meme si on est en mode maille pour afficher
        # la liste des dernières obs
        observations = vmObservationsRepository.getObservationsChilds(
            params={
                "last_obs": str(current_app.config["NB_DAY_LAST_OBS"]) + " day",
                "fields": "taxons,medias",
            },
        )
        if current_app.config["AFFICHAGE_MAILLE"]:
            observations_mailles = vmObservationsMaillesRepository.getObservationsMaillesChilds(
                params={
                    "last_obs": str(current_app.config["NB_DAY_LAST_OBS"]) + " day",
                    "fields": "taxons,ids_obs",
                }
            )

    if current_app.config["AFFICHAGE_EN_CE_MOMENT"]:
        mostViewTaxon = vmTaxonsMostView.mostViewTaxon()
    else:
        mostViewTaxon = []

    if current_app.config["AFFICHAGE_RANG_STAT"]:
        customStatMedias = vmObservationsRepository.genericStatMedias(
            current_app.config["RANG_STAT"]
        )
    else:
        customStatMedias = []

    if current_app.config["AFFICHAGE_NOUVELLES_ESPECES"]:
        lastDiscoveries = vmObservationsRepository.getLastDiscoveries()
    else:
        lastDiscoveries = []
    group2_inpn = vmTaxonsRepository.get_group_inpn("group2_inpn")
    personal_data = False
    args_personal_data = request.args.get("personal_data")
    if args_personal_data and args_personal_data.lower() == "true":
        personal_data = True

    return render_template(
        "templates/home/_main.html",
        observations=observations,
        observations_mailles=observations_mailles,
        mostViewTaxon=mostViewTaxon,
        customStatMedias=customStatMedias,
        lastDiscoveries=lastDiscoveries,
        personal_data=personal_data,
        group2_inpn=group2_inpn,
        listTaxons=listTaxons,
        nb_taxons=nb_taxons,
    )


@main.route("/espece/<int(signed=True):cd_nom>", methods=["GET", "POST"])
def ficheEspece(cd_nom):
    # Get cd_ref from cd_nom
    cd_ref = vmTaxrefRepository.get_cd_ref(cd_nom)

    # Redirect to cd_ref if cd_nom is a synonym. Redirection is better for SEO.
    if cd_ref != cd_nom:
        return redirect(url_for(request.endpoint, cd_nom=cd_ref))

    # Get data to render template
    taxon = vmTaxrefRepository.searchEspece(cd_ref)
    altitudes = vmAltitudesRepository.getAltitudesChilds(cd_ref)
    months = vmMoisRepository.getMonthlyObservationsChilds(cd_ref)
    organism_stats = None
    if current_app.config["ORGANISM_MODULE"]:
        organism_stats = vmCorTaxonOrganismRepository.getTaxonOrganism(cd_ref)
    synonyme = vmTaxrefRepository.getSynonymy(cd_ref)
    areas = vmAreasRepository.getAreasByTaxon(cd_ref)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(cd_ref)
    firstPhoto = vmMedias.getFirstPhoto(cd_ref, current_app.config["ATTR_MAIN_PHOTO"])
    photoCarousel = vmMedias.getPhotoCarousel(cd_ref, current_app.config["ATTR_OTHER_PHOTO"])
    videoAudio = vmMedias.getVideo_and_audio(
        cd_ref,
        current_app.config["ATTR_AUDIO"],
        current_app.config["ATTR_VIDEO_HEBERGEE"],
        current_app.config["ATTR_YOUTUBE"],
        current_app.config["ATTR_DAILYMOTION"],
        current_app.config["ATTR_VIMEO"],
    )
    articles = vmMedias.getLinks_and_articles(
        cd_ref, current_app.config["ATTR_LIEN"], current_app.config["ATTR_PDF"]
    )
    taxonAttrs = vmCorTaxonAttribut.getAttributesTaxon(
        cd_ref,
        current_app.config["TAXHUB_DISPLAYED_ATTR"],
    )

    liens_focus = []
    if current_app.config.get("TYPES_MEDIAS_LENS_FOCUS"):
        liens_config = current_app.config["TYPES_MEDIAS_LENS_FOCUS"]
        media_type_ids = list({t["type_media_id"] for t in liens_config})
        liens_focus = vmMedias.get_liens_focus(cd_ref, media_type_ids)
        icones_by_media_type = {
            i["type_media_id"]: i["icon"] for i in liens_config if i.get("icon")
        }
        for lien in liens_focus:
            lien["icon"] = icones_by_media_type.get(lien["id_type"], "")

    observers = vmObservationsRepository.getObservers(cd_ref)

    organisms = vmOrganismsRepository.getListOrganism(cd_ref)

    statuts = vmStatutBdcRepository.get_taxons_statut_bdc(cd_ref)
    groupes_statuts = _make_groupes_statuts(statuts)
    groupes_statuts_have_labels = any([groupe.get("label") for groupe in groupes_statuts])

    return render_template(
        "templates/speciesSheet/_main.html",
        taxon=taxon,
        listeTaxonsSearch=[],
        observations=[],
        cd_ref=cd_ref,
        altitudes=altitudes,
        months=months,
        organism_stats=organism_stats,
        synonyme=synonyme,
        areas=areas,
        taxonomyHierarchy=taxonomyHierarchy,
        firstPhoto=firstPhoto,
        photoCarousel=photoCarousel,
        videoAudio=videoAudio,
        articles=articles,
        taxonAttrs=taxonAttrs,
        liens_focus=liens_focus,
        observers=observers,
        organisms=organisms,
        groupesStatuts=groupes_statuts,
        groupesStatutsHaveLabels=groupes_statuts_have_labels,
        areas_sensitivity_level=corSensitivityAreaRepository.get_sensitivity_areas_level(),
    )


def _make_groupes_statuts(statuts):
    """Groupe les statuts de la BDC suivant la configuration GROUPES_STATUTS.

    Retourne une liste de groupes. Un groupe est de la forme :

        {
            "label": "Monde",
            "statuts": [
                {
                    "cd_type_statut": "LRM",
                    "lb_type_statut": "Liste Rouge Mondiale",
                    "cd_sig": "WORLD",
                    "code_statut": "LC",
                    "label_statut": "Préoccupation mineure",
                    "rq_statut": ""
                }
            ]
        }
    """

    def is_statut_in_groupe(statut, groupe):
        for filter_item in groupe["filters"]:
            if filter_item.get("cd_type_statut"):
                has_valid_type = statut["cd_type_statut"] == filter_item.get("cd_type_statut")
            else:
                has_valid_type = True

            if filter_item.get("cd_sig"):
                has_valid_sig = statut["cd_sig"] == filter_item.get("cd_sig")
            else:
                has_valid_sig = True

            if has_valid_type and has_valid_sig:
                return True
        else:
            return False

    groupes_statuts = []
    for config_groupe in current_app.config["GROUPES_STATUTS"]:
        groupe = {"label": config_groupe.get("label", ""), "statuts": []}
        for statut in statuts:
            if is_statut_in_groupe(statut, config_groupe):
                groupe["statuts"].append(statut)
        if groupe["statuts"]:
            groupes_statuts.append(groupe)
    return groupes_statuts


@main.route("/area/<int:id_area>", methods=["GET", "POST"])
def area(id_area):
    area = vmAreasRepository.getAreaFromIdArea(id_area)
    stats_area = vmAreasRepository.getStatsByArea(id_area)
    listTaxons = vmTaxonsRepository.getListTaxon(id_area=id_area, params=MultiDict({"page": 0}))
    group2_inpn = vmTaxonsRepository.get_group_inpn("group2_inpn", id_area)
    return render_template(
        "templates/areaSheet/_main.html",
        stats_area=stats_area,
        areaInfos=area,
        id_area=id_area,
        listTaxons=listTaxons,
        group2_inpn=group2_inpn,
    )


@main.route("/liste/<int(signed=True):cd_ref>", methods=["GET", "POST"])
def ficheRangTaxonomie(cd_ref=None):
    nb_taxons = vmTaxonsRepository.get_nb_taxons(cd_ref=cd_ref)
    referenciel = vmTaxrefRepository.getInfoFromCd_ref(cd_ref)
    taxonomyHierarchy = vmTaxrefRepository.getAllTaxonomy(cd_ref)
    observers = vmObservationsRepository.getObservers(cd_ref)
    listTaxons = vmTaxonsRepository.getListTaxon(cd_ref=cd_ref, params=MultiDict({"page": 0}))

    return render_template(
        "templates/taxoRankSheet/_main.html",
        listTaxons=listTaxons,
        nb_taxons=nb_taxons,
        referenciel=referenciel,
        taxonomyHierarchy=taxonomyHierarchy,
        observers=observers,
        cd_ref=cd_ref,
    )


@main.route("/groupe/<groupe>", methods=["GET", "POST"])
def ficheGroupe(groupe):
    groups = vmTaxonsRepository.getAllINPNgroup()
    nb_taxons = vmTaxonsRepository.get_nb_taxons(group_name=groupe)
    observers = vmObservationsRepository.getGroupeObservers(groupe)
    listTaxons = vmTaxonsRepository.getListTaxon(group_name=groupe, params=MultiDict({"page": 0}))

    return render_template(
        "templates/groupSheet/_main.html",
        listTaxons=listTaxons,
        nb_taxons=nb_taxons,
        referenciel=groupe,
        groups=groups,
        observers=observers,
    )


if current_app.config["AFFICHAGE_GALERIE_PHOTO"]:

    @main.route("/photos", methods=["GET", "POST"])
    def photos():
        groups = vmTaxonsRepository.getINPNgroupPhotos()
        return render_template("templates/photoGalery/_main.html", groups=groups)


@main.route("/static_pages/<page>", methods=["GET", "POST"])
def get_staticpages(page):
    if page not in current_app.config["STATIC_PAGES"]:
        abort(404)
    static_page = current_app.config["STATIC_PAGES"][page]
    return render_template(
        static_page["template"],
    )


@main.route("/sitemap.xml", methods=["GET"])
def sitemap():
    """Generate sitemap.xml iterating over static and dynamic routes to make a list of urls and date modified"""
    pages = []
    ten_days_ago = datetime.now() - timedelta(days=10)
    for static_page in current_app.config["STATIC_PAGES"]:
        url = url_for("main.get_staticpages", page=static_page, _external=True)
        pages.append([url, ten_days_ago])
    pages.extend(
        [
            [url_for("main.photos", _external=True), ten_days_ago],
            [url_for("main.sitemap", _external=True), ten_days_ago],
            [url_for("main.sitemap_ui", _external=True), ten_days_ago],
            [url_for("main.robots", _external=True), ten_days_ago],
        ]
    )

    # get dynamic routes for blog
    species = db.session.query(vmTaxons.VmTaxons).order_by(vmTaxons.VmTaxons.cd_ref).all()
    for species in species:
        url = url_for("main.ficheEspece", cd_nom=species.cd_ref, _external=True)
        modified_time = ten_days_ago
        pages.append([url, modified_time])

    # Pour ne remonter que les areas ayant des observations :
    areas = (
        db.session.query(vmAreas.VmAreasWithObs)
        .filter(vmAreas.VmAreasWithObs.type_code.in_(current_app.config["TYPE_TERRITOIRE_SHEET"]))
        .order_by(vmAreas.VmAreasWithObs.area_name)
        .all()
    )

    for area in areas:
        url = url_for("main.area", id_area=area.id_area, _external=True)
        modified_time = ten_days_ago
        pages.append([url, modified_time])

    sitemap_template = render_template(
        "templates/sitemap.xml", pages=pages, last_modified=ten_days_ago
    )
    response = make_response(sitemap_template)
    response.headers["Content-Type"] = "application/xml"
    return response


@main.route("/sitemap", methods=["GET"])
@main.route("/sitemap.html", methods=["GET"])
def sitemap_ui():
    """Generate sitemap iterating over static and dynamic routes to make a list of urls"""
    pages = {
        "static": {
            "title": gettext("static pages"),
            "values": [
                {"url": url_for("main.index"), "label": gettext("home page")},
                {"url": url_for("main.photos"), "label": gettext("photos")},
            ],
        },
        "areas": {
            "title": gettext("zoning pages"),
            "values": [],
        },
        "groups": {"title": gettext("species sheet by groups"), "values": {}},
    }

    for static_page in current_app.config["STATIC_PAGES"]:
        url_static_page = url_for("main.get_staticpages", page=static_page)
        data_page = current_app.config["STATIC_PAGES"][static_page]
        pages["static"]["values"].append({"url": url_static_page, "label": data_page["title"]})

    # get dynamic routes for blog
    species = db.session.query(vmTaxons.VmTaxons).order_by(vmTaxons.VmTaxons.nom_complet).all()
    for species in species:
        if species.group2_inpn not in pages["groups"]["values"]:
            group_url = url_for("main.ficheGroupe", groupe=species.group2_inpn)
            pages["groups"]["values"][species.group2_inpn] = {
                "url": group_url,
                "label": species.group2_inpn,
                "species": [],
            }

        url_species = url_for("main.ficheEspece", cd_nom=species.cd_ref)
        pages["groups"]["values"][species.group2_inpn]["species"].append(
            {"url": url_species, "label": species.lb_nom}
        )

    # Pour ne remonter que les areas ayant des observations :
    areas = (
        db.session.query(vmAreas.VmAreasWithObs)
        .filter(vmAreas.VmAreasWithObs.type_code.in_(current_app.config["TYPE_TERRITOIRE_SHEET"]))
        .order_by(vmAreas.VmAreasWithObs.area_name)
        .all()
    )
    for area in areas:
        url = url_for("main.area", id_area=area.id_area)
        pages["areas"]["values"].append({"url": url, "label": area.area_name})

    return render_template("templates/sitemap.html", pages=pages)


@main.route("/robots.txt", methods=["GET"])
def robots():
    robots_template = render_template("static/custom/robots.txt")
    response = make_response(robots_template)
    response.headers["Content-type"] = "text/plain"

    return response
