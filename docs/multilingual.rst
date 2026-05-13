
========================
Multilingual module (EN)
========================


The module used for multilingual is Flask-Babel (https://flask-babel.tkte.ch).

You can activate or deactivate this module by changing ``MULTILINGUAL`` setting value (``true`` or ``false``) in your ``config.py`` file.

If you do so, you have to set ``DEFAULT_LANGUAGE`` with your language key. Example: ``'fr'`` for French. Make sure that your language is listed in ``LANGUAGES`` setting in your ``config.py`` file.

Here are the commands that you can use to add a language, adding text to translate, or update translations.

All the commands should be used in your atlas path in a command prompt.

The ``atlas/messages.pot`` file is a translation template, automatically generated with browsing all .html files of the project.
It is used to generate and add keys in .po files of each language.
Once .po files have been manually updated, the final command will generate the compiled .mo files used by the application.

Adding a language
=================

First, go to the ``config.py`` file and add your language in the same way as the other languages already available.

Activate your venv : ``source venv/bin/activate``

Then in your command prompt, go in your atlas path and use these commmands.

::

    # Extract your strings from html files | create or update .pot file
    pybabel extract -F babel.cfg --project=GeoNature-Atlas --version=$(cat ../VERSION) -o messages.pot .

    # Create first translation, here in french (fr) | create .po file
    pybabel init -i messages.pot -d translations -l fr

    # To compile translations | create .mo file
    make compile_messages

Adding strings
==============

::

    # Extraire vos nouvelles chaînes de caractères des fichiers html | créer un fichier .pot et mettre à jour les fichiers .po
    make messages

    # Pour compiler les traductions | créer un fichier .mo
    make compile_messages

Modifying a string already in .po files
=======================================

Edit the ``.po`` file to change, then compile the translation files to generate to ``.mo`` files.

::

    # To compile translations | create .mo file
    make compile_messages
