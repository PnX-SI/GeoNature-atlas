# -*- coding:utf-8 -*-
from flask import current_app, g
from flask_babel import gettext, get_translations


def get_locale():
    # if MULTILINGUAL, valid language is in g via before_request_hook
    if current_app.config["MULTILINGUAL"]:
        return g.lang_code
    return current_app.config["DEFAULT_LANGUAGE"]


def get_tranlated_labels():
    """
    Return a dict of all translated labels
    """

    translations = get_translations()
    return {msg: trans for msg, trans in translations._catalog.items() if msg}
