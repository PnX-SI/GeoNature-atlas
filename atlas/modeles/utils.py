# -*- coding:utf-8 -*-

import unicodedata


def deleteAccent(string):
    if string is None:
        return None
    return unicodedata.normalize("NFD", string).encode("ascii", "ignore").decode("utf-8")


def findPath(row):
    if row.chemin == None and row.url == None:
        return None
    elif row.chemin != None and row.chemin != "":
        return row.chemin
    else:
        return row.url
