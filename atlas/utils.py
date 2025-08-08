# -*- coding:utf-8 -*-
from flask import current_app, g


def get_locale():
    # if MULTILINGUAL, valid language is in g via before_request_hook
    if current_app.config["MULTILINGUAL"]:
        return g.lang_code
    return current_app.config["DEFAULT_LANGUAGE"]
