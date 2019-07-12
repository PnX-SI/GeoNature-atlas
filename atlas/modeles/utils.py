
# -*- coding:utf-8 -*-

from ..utils import engine
from sqlalchemy import MetaData, Table
import unicodedata
from ..configuration import config


class GenericTable:
    def __init__(self, tableName, schemaName):
        # engine = create_engine(database_connection, client_encoding='utf8', echo = False)
        meta = MetaData(bind=engine)
        meta.reflect(schema=schemaName, views=True)
        self.tableDef = meta.tables[tableName]
        self.columns = [column.name for column in self.tableDef.columns]

    def serialize(self, data):
        return serializeQuery(data, self.columns)

def serializeQuery( data, columnDef):
    rows = [
        {c['name'] : getattr(row, c['name']) for c in columnDef if getattr(row, c['name']) != None } for row in data
    ]
    return rows


def deleteAccent(string):
    if string is None:
        return None
    return unicodedata.normalize('NFD', string).encode('ascii', 'ignore').decode('utf-8')

def findPath(row):
        if row.chemin == None  and row.url == None:
            return None
        elif row.chemin != None and row.chemin != '':
            return row.chemin
        else:
            return row.url
