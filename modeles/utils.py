#! /usr/bin/python
# -*- coding:utf-8 -*-
from atlas.manage import engine
from sqlalchemy import MetaData, Table

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