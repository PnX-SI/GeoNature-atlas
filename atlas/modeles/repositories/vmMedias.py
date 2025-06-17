# -*- coding:utf-8 -*-


from flask import current_app
from sqlalchemy.sql import text, func, select, or_

from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles import utils
from atlas.app import create_app
from atlas.env import db


def _format_media(r):
    """
    Return a dict from request of the t_media table
    """
    return {
        "id_media": r.id_media,
        "cd_ref": r.cd_ref,
        "path": utils.findPath(r),
        "title": deleteNone(r.titre),
        "author": deleteNone(r.auteur),
        "description": deleteNone(r.desc_media),
        "id_type": r.id_type,
        "date": str(r.date_media),
        "licence": r.licence,
        "source": r.source,
    }


def deleteNone(r):
    if r is None:
        return ""
    else:
        return r


def getFirstPhoto(session, cd_ref, id):
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref))
    req = (
        session.query(VmMedias)
        .filter(
            or_(VmMedias.cd_ref.in_(childs_ids), VmMedias.cd_ref == cd_ref), VmMedias.id_type == id
        )
        .limit(1)
    )
    for r in req:
        return _format_media(r)


def getPhotoCarousel(session, cd_ref, id):
    childs_ids = select(func.atlas.find_all_taxons_childs(cd_ref).label("cd_ref"))
    req = session.query(VmMedias).filter(
        or_(VmMedias.cd_ref.in_(childs_ids), VmMedias.cd_ref == cd_ref), VmMedias.id_type == id
    )
    return [_format_media(r) for r in req]


def switchMedia(row):
    media_template = {  # noqa
        current_app.config["ATTR_AUDIO"]: "{path}",
        current_app.config["ATTR_VIDEO_HEBERGEE"]: "{path}",
        current_app.config[
            "ATTR_YOUTUBE"
        ]: """
            <iframe
                width='100%'
                height='315'
                src='https://www.youtube.com/embed/{path}'
                frameborder='0'
                allowfullscreen>
            </iframe>""",
        current_app.config[
            "ATTR_DAILYMOTION"
        ]: """
            <iframe
                frameborder='0'
                width='100%'
                height='315'
                src='//www.dailymotion.com/embed/video/{path}'
                allowfullscreen>
            </iframe>""",
        current_app.config[
            "ATTR_VIMEO"
        ]: """
            <iframe
                src='https://player.vimeo.com/video/{path}?color=ffffff&title=0&byline=0&portrait=0'
                width='640'
                height='360'
                frameborder='0'
                webkitallowfullscreen
                mozallowfullscreen
                allowfullscreen>
            </iframe>""",
    }

    goodPath = str()
    if not row.chemin and not row.url:
        return None
    elif row.chemin:
        goodPath = row.chemin
    else:
        goodPath = row.url

    if not goodPath:
        return None
    return media_template[row.id_type].format(path=goodPath)


def getVideo_and_audio(session, cd_ref, id5, id6, id7, id8, id9):
    req = (
        session.query(VmMedias)
        .filter(VmMedias.id_type.in_((id5, id6, id7, id8, id9)), VmMedias.cd_ref == cd_ref)
        .order_by(VmMedias.date_media.desc())
    )
    tabMedias = {"audio": list(), "video": list()}
    for r in req:
        path = switchMedia(r)
        if path is not None:
            temp = {
                "id_type": r.id_type,
                "path": path,
                "title": r.titre,
                "author": deleteNone(r.auteur),
                "description": deleteNone(r.desc_media),
                "id_media": r.id_media,
                "source": r.source,
                "licence": r.licence,
            }
            if r.id_type == current_app.config["ATTR_AUDIO"]:
                tabMedias["audio"].append(temp)
            else:
                tabMedias["video"].append(temp)
    return tabMedias


def getLinks_and_articles(session, cd_ref, id3, id4):
    req = (
        session.query(VmMedias)
        .filter(VmMedias.id_type.in_((id3, id4)), VmMedias.cd_ref == cd_ref)
        .order_by(VmMedias.date_media.desc())
    )
    return [_format_media(r) for r in req]


def get_liens_importants(session, cd_ref, media_ids):
    req = (
        session.query(VmMedias)
        .filter(VmMedias.id_type == func.any(media_ids), VmMedias.cd_ref == cd_ref)
        .order_by(VmMedias.date_media.desc())
    )
    return [_format_media(r) for r in req]


def getPhotosGallery(session, id1, id2):
    req = (
        session.query(VmMedias, VmTaxons.nom_vern, VmTaxons.lb_nom, VmTaxons.nb_obs)
        .join(VmTaxons, VmTaxons.cd_ref == VmMedias.cd_ref)
        .filter(VmMedias.id_type.in_((id1, id2)))
        .order_by(func.random())
    )

    tab_photos = []
    for vm_media, nom_vern, lb_nom, nb_obs in req:
        if nom_vern:
            nom_verna = nom_vern.split(",")
            taxonName = nom_verna[0] + " | <i>" + lb_nom + "</i>"
        else:
            taxonName = "<i>" + lb_nom + "</i>"

        photo = _format_media(vm_media)  # vm_media est un objet VmMedias
        photo["name"] = taxonName
        photo["nb_obs"] = nb_obs
        tab_photos.append(photo)
    return tab_photos


def getPhotosGalleryByGroup(session, id1, id2, INPNgroup):
    req = (
        session.query(VmMedias, VmTaxons.nom_vern, VmTaxons.lb_nom, VmTaxons.nb_obs)
        .join(VmTaxons, VmTaxons.cd_ref == VmMedias.cd_ref)
        .filter(VmMedias.id_type.in_((id1, id2)), VmTaxons.group2_inpn == INPNgroup)
        .order_by(func.random())
    )

    tab_photos = []
    for vm_media, nom_vern, lb_nom, nb_obs in req:
        if nom_vern:
            nom_verna = nom_vern.split(",")
            taxonName = nom_verna[0] + " | <i>" + lb_nom + "</i>"
        else:
            taxonName = "<i>" + lb_nom + "</i>"

        photo = _format_media(vm_media)  # vm_media est un objet VmMedias
        photo["name"] = taxonName
        photo["nb_obs"] = nb_obs
        tab_photos.append(photo)
    return tab_photos
