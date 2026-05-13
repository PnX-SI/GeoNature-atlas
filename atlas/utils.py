# -*- coding:utf-8 -*-
from flask import current_app, g, session, request, url_for, redirect
from flask_babel import gettext, get_translations


def get_tranlated_labels():
    """
    Return a dict of all translated labels
    """

    translations = get_translations()
    return {msg: trans for msg, trans in translations._catalog.items() if msg}


# Order of language process :
# 1. : @app.url_value_preprocessor is call, it get the language from the URL and store it in g (only if MULTILINGUAL is True)
#         -> even if MULTILINGUAL is True, we can access to to URL without lang_code prefix (blueprints are register twice - with prefix and without prefix)
#         -> g.lang_code is set from (in this order) :
#               - URL with lang_code prefix
#               - from browser language is not url prefix
#               - from DEFAULT_LANGUAGE is no language is browser
# 2. A redirection is done in main blueprint if we access / to redirect to /<lang_code>
# 3. : get_local -> it is used even if MULTILINGUAL is False. It takes g.lang_code if exist, else DEFAULT_LANGUAGE
# 4. : @app.url_defaults rewrite all url_for with current language from g (only if MULTILINGUAL is True)
def multilingual_utils(app):
    if app.config["MULTILINGUAL"]:

        @app.url_value_preprocessor
        def pull_lang_code(endpoint, values):
            # if no lang_code in URL
            if not values:
                g.lang_code = get_default_language()
                return
            lang_code = values.pop("lang_code", None)
            if lang_code and lang_code in current_app.config["AVAILABLE_LANGUAGES"]:
                g.lang_code = lang_code
            # if lang code in url but not in AVAILABLE_LANGUAGES
            if not hasattr(g, "lang_code") or g.lang_code is None:
                g.lang_code = get_default_language()

        @app.url_defaults
        def add_language_code(endpoint, values):
            if "lang_code" not in values and hasattr(g, "lang_code"):
                if app.url_map.is_endpoint_expecting(endpoint, "lang_code"):
                    values["lang_code"] = g.lang_code


def get_default_language():
    """
    Return default language when language not in URL
    """
    return request.accept_languages.best_match(
        current_app.config["AVAILABLE_LANGUAGES"]
    ) or current_app.config.get("DEFAULT_LANGUAGE", "fr")


def get_locale():
    if current_app.config["MULTILINGUAL"]:
        return getattr(g, "lang_code")
    return current_app.config["DEFAULT_LANGUAGE"]


def get_current_url_prefix():
    if current_app.config["MULTILINGUAL"]:
        return f"/{get_locale()}"
    else:
        return ""
