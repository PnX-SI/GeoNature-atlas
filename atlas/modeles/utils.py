# -*- coding:utf-8 -*-

import unicodedata
from flask import current_app


def deleteAccent(string):
    if string is None:
        return None
    return unicodedata.normalize("NFD", string).encode("ascii", "ignore").decode("utf-8")


def findPath(row):
    if row.chemin == None and row.url == None:
        return None
    elif row.chemin != None and row.chemin != "":
        return current_app.config["REMOTE_MEDIAS_URL"] + row.chemin
    else:
        return row.url
