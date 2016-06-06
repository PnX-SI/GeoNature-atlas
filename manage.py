#!/usr/bin/env python

from atlas import create_app
from sqlalchemy import create_engine

globalApp = create_app('development')
app = globalApp['app']
engine = globalApp['engine']

def loadSession():
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    session = Session()
    return session


