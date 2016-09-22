#! /usr/bin/python
# -*- coding:utf-8 -*-

#from modele import utils
from .. import utils
from ...configuration import config


from sqlalchemy.sql import text

def deleteNone(r):
    if r == None:
        return ''
    else:
        return r

def getFirstPhoto(connection, cd_ref, id):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE (cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref) AND id_type=:thisid"
    req = connection.execute(text(sql), thiscdref = cd_ref, thisid=id)
    
    for r in req:
        return {'path': utils.findPath(r), 'title': deleteNone(r.titre), 'author': deleteNone(r.auteur)}

def getPhotoCarousel(connection, cd_ref, id):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE (cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref) AND id_type= :thisid"
    req = connection.execute(text(sql), thiscdref = cd_ref, thisid=id)
    tabURL = list()
    for r in req:
        tabURL.append({'path': utils.findPath(r), 'title': deleteNone(r.titre), 'author': deleteNone(r.auteur)})
    return tabURL

def switchMedia(raw):
    goodPath = str()
    if raw.chemin != None and raw.chemin[0] == 's':
        goodPath = config.URL_MEDIAS+raw.chemin
    else:
        goodPath = raw.url

    return { config.ATTR_AUDIO : goodPath,
             config.ATTR_VIDEO_HEBERGEE: goodPath,
             config.ATTR_YOUTUBE : "<iframe width='100%' height='315' src='https://www.youtube.com/embed/"+raw.url+"' frameborder='0' allowfullscreen></iframe>",
             config.ATTR_DAILYMOTION : "<iframe frameborder='0' width='100%' height='315' src='//www.dailymotion.com/embed/video/"+raw.url+"' allowfullscreen></iframe>",
             config.ATTR_VIMEO : "<iframe src='https://player.vimeo.com/video/"+raw.url+"?color=ffffff&title=0&byline=0&portrait=0' width='640' height='360'\
             frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"}

def getVideo_and_audio(connection, cd_ref, id5, id6, id7, id8, id9):
    sql = "SELECT * \
    FROM atlas.vm_medias \
    WHERE id_type in (:id5, :id6, :id7, :id8, :id9) AND cd_ref = :thiscdref \
    ORDER BY date_media DESC "

    req = connection.execute(text(sql), thiscdref = cd_ref, id5=id5, id6=id6, id7=id7, id8=id8, id9=id9)
    tabMedias = {'audio' :list(), 'video': list()} 
    for r in req:
        path = switchMedia(r)
        temp = {'id_type': r.id_type, 'path': path[r.id_type], 'title': r.titre, 'author': deleteNone(r.auteur), 'description': deleteNone(r.desc_media)}
        if r.id_type == 5:
            tabMedias['audio'].append(temp)
        else:
            tabMedias['video'].append(temp)
    return tabMedias

def getLinks_and_articles(connection, cd_ref, id3, id4):
    sql = "SELECT * \
    FROM atlas.vm_medias \
    WHERE id_type in (:id3, :id4) AND cd_ref = :thiscdref\
    ORDER BY date_media DESC"
    req = connection.execute(text(sql), thiscdref = cd_ref, id3=id3, id4=id4)
    tabArticles = list()
    for r in req:
        temp = {'id_type': r.id_type, 'path': utils.findPath(r), 'title': deleteNone(r.titre), 'author':deleteNone(r.auteur), 'description': deleteNone(r.desc_media), 'date': deleteNone(r.date_media)}
        tabArticles.append(temp)
    return tabArticles


def getPhotosGallery(connection, id1, id2):
    sql= """ SELECT m.url, m.chemin, t.nom_vern, t.lb_nom, m.cd_ref, m.auteur, m.titre
         FROM atlas.vm_medias m
        JOIN atlas.vm_taxons t ON t.cd_ref = m.cd_ref
        WHERE m.id_type IN (:thisID1, :thisID2)
        ORDER BY RANDOM()"""
    req = connection.execute(text(sql), thisID1 = id1, thisID2 = id2)
    tabPhotos = list()
    for r in req:
        if r.nom_vern != None:
            nom_verna = r.nom_vern.split(',')
            taxonName = nom_verna[0]+' | ' + r.lb_nom
        else:
            taxonName = r.lb_nom
        temp={'path':utils.findPath(r), 'name':taxonName, 'cd_ref':r.cd_ref,'author': r.auteur, 'title':r.titre}
        tabPhotos.append(temp)
    return tabPhotos


def getPhotosGalleryByGroup(connection, id1, id2, INPNgroup):
    sql= """ SELECT m.url, m.chemin, t.nom_vern, t.lb_nom, m.cd_ref, m.auteur, m.titre
         FROM atlas.vm_medias m
        JOIN atlas.vm_taxons t ON t.cd_ref = m.cd_ref
        WHERE m.id_type IN  (:thisID1, :thisID2) AND t.group2_inpn = :thisGroup
        ORDER BY RANDOM()"""
    req = connection.execute(text(sql), thisID1=id1, thisID2=id2, thisGroup=INPNgroup)
    tabPhotos = list()
    for r in req:
        if r.nom_vern != None:
            nom_verna = r.nom_vern.split(',')
            taxonName = nom_verna[0]+' | ' + r.lb_nom
        else:
            taxonName = r.lb_nom
        temp={'path':utils.findPath(r), 'name':taxonName, 'cd_ref':r.cd_ref, 'author': r.auteur, 'title':r.titre}
        tabPhotos.append(temp)
    return tabPhotos




