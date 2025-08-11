# -*- coding:utf-8 -*-
from flask import current_app, g
from flask_babel import gettext


def get_locale():
    # if MULTILINGUAL, valid language is in g via before_request_hook
    if current_app.config["MULTILINGUAL"]:
        return g.lang_code
    return current_app.config["DEFAULT_LANGUAGE"]


def get_tranlated_labels():
    """
    Return a dict of translated labels regarding the context of the app (multiple areas or not)
    """
    isOnlyMunicipalities = False
    if current_app.config["TYPE_TERRITOIRE_SHEET"] == ["COM"]:
        isOnlyMunicipalities = True
    return {
        "territories": (
            gettext("municipalities") if isOnlyMunicipalities else gettext("territories")
        ),
        "territory": gettext("municipality") if isOnlyMunicipalities else gettext("territory"),
        "search_area": gettext("search.city") if isOnlyMunicipalities else gettext("search.area"),
    }
