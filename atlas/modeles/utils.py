import unicodedata

from flask import current_app


def is_true_param(params, name):
    """Return whether a request parameter represents a true value."""
    value = params.get(name)
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "on"}
    return value is True


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
