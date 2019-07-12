
# -*- coding:utf-8 -*-

from sqlalchemy import create_engine
from .configuration.config import database_connection
from sqlalchemy.pool import QueuePool
engine = create_engine(database_connection, client_encoding='utf8', echo = False, poolclass=QueuePool)


def loadSession():
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    session = Session()
    return session

def format_number(val):
    """ Ajouter des espaces en séparateur de milliers """
    return '{:,}'.format(val).replace(',',' ')
