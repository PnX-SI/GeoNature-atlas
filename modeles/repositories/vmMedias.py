#! /usr/bin/python
# -*- coding:utf-8 -*-

from modeles import utils
import config


from sqlalchemy.sql import text

def getFirstPhoto(connection, cd_ref):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref AND id_type=1"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    
    for r in req:
        return {'path': utils.findPath(r), 'title': r.titre, 'author': r.auteur}

def getPhotoCarousel(connection, cd_ref):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref AND id_type=2"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    tabURL = list()
    for r in req:
         tabURL.append({'path': utils.findPath(r), 'title': r.titre, 'author': r.auteur})
    return tabURL

def switchMedia(raw):
    goodPath = str()
    if raw.url == None:
        goodPath = config.URL_MEDIAS+raw.chemin
    else:
        goodPath = raw.url

    return { 5 : goodPath,
             6: goodPath,
             7 : "<iframe width='100%' height='315' src='https://www.youtube.com/embed/"+raw.url+"' frameborder='0' allowfullscreen></iframe>",
             8 : "<iframe frameborder='0' width='100%' height='315' src='//www.dailymotion.com/embed/video/"+raw.url+"' allowfullscreen></iframe>",
             9 : "<iframe src='https://player.vimeo.com/video/"+raw.url+"?color=ffffff&title=0&byline=0&portrait=0' width='640' height='360'\
             frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"}

def getVideo_and_audio(connection, cd_ref):
    sql = "SELECT * \
    FROM atlas.vm_medias \
    WHERE id_type in (5, 6, 7, 8, 9) AND cd_ref = :thiscdref \
    ORDER BY date_media DESC "

    req = connection.execute(text(sql), thiscdref = cd_ref)
    tabMedias = {'audio' :list(), 'video': list()} 
    for r in req:
        path = switchMedia(r)
        temp = {'id_type': r.id_type, 'path': path[r.id_type], 'title': r.titre, 'author':r.auteur, 'description': r.desc_media}
        if r.id_type == 5:
            tabMedias['audio'].append(temp)
        else:
            tabMedias['video'].append(temp)
    return tabMedias

def getLinks_and_articles(connection, cd_ref):
    sql = "SELECT * \
    FROM atlas.vm_medias \
    WHERE id_type in (3, 4) AND cd_ref = :thiscdref\
    ORDER BY date_media DESC"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    tabArticles = list()
    for r in req:
        temp = {'id_type': r.id_type, 'url': r.url, 'title': r.titre, 'author':r.auteur, 'description': r.desc_media, 'date': r.date_media}
        tabArticles.append(temp)
    return tabArticles






