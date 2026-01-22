# -*- coding:utf-8 -*-
from flask import current_app, g, session, request
from flask_babel import gettext, get_translations


def get_locale():
    if current_app.config["MULTILINGUAL"]:
        lang = session.get("language")
        if lang and lang in current_app.config["AVAILABLE_LANGUAGES"]:
            return lang
        return request.accept_languages.best_match(
            current_app.config["AVAILABLE_LANGUAGES"]
        ) or current_app.config.get("DEFAULT_LANGUAGE", "fr")
    return current_app.config["DEFAULT_LANGUAGE"]


def get_tranlated_labels():
    """
    Return a dict of all translated labels
    """

    translations = get_translations()
    return {msg: trans for msg, trans in translations._catalog.items() if msg}
