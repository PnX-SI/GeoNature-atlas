# -*- coding:utf-8 -*-

from ..utils import engine
from sqlalchemy import MetaData, Table
import unicodedata
from ..configuration import config


def deleteAccent(string):
    if string is None:
        return None
    return (
        unicodedata.normalize("NFD", string).encode("ascii", "ignore").decode("utf-8")
    )


def findPath(row):
    if row.chemin == None and row.url == None:
        return None
    elif row.chemin != None and row.chemin != "":
        return row.chemin
    else:
        return row.url
