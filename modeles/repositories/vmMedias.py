#! /usr/bin/python
# -*- coding:utf-8 -*-

from sqlalchemy.sql import text

def getFirstPhoto(connection, cd_ref):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref AND id_type=1"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    for r in req:
        return {'url':r.url, 'path': r.chemin, 'title': r.titre, 'author': r.auteur}

def getPhotoCarousel(connection, cd_ref):
    sql= "SELECT * \
    FROM atlas.vm_medias \
    WHERE cd_ref IN ( SELECT * FROM atlas.find_all_taxons_childs(:thiscdref)) OR cd_ref = :thiscdref AND id_type=2"
    req = connection.execute(text(sql), thiscdref = cd_ref)
    tabURL = list()
    for r in req:
         tabURL.append({'url': r.url, 'path': r.chemin, 'title': r.titre, 'author': r.auteur})
    return tabURL