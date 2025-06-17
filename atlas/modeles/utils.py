# -*- coding:utf-8 -*-
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine
from atlas.configuration.config import SQLALCHEMY_DATABASE_URI

from contextlib import contextmanager
import unicodedata


engine = create_engine(SQLALCHEMY_DATABASE_URI, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


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


@contextmanager
def get_session():
    """Créer une session pour les opérations sur la base."""
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
