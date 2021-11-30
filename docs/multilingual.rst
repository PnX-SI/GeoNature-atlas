
==========================
MULTILINGUAL MODULE : (EN)
==========================

The module used for multilingual is Flask-Babel (https://flask-babel.tkte.ch).

You can activate or deactivate this module by changing ``MULTILINGUAL`` setting value (``true`` or ``false``) in your ``config.py`` file.

If you do so, you have to set ``DEFAULT_LANGUAGE`` with your language key. Example: ``'fr'`` for French. Make sure that your language is listed in ``LANGUAGES`` setting in your ``config.py`` file.

Here are the commands that you can use to add a language, adding text to translate, or update translations.

All the commands should be used in your atlas path in a command prompt.

The ``atlas/messages.pot`` file is a translation template, automatically generated with browsing all .html and .sample files of the project. 
It is used to generate and add keys in .po files of each language. 
Once .po files have been manually updated, the final command will generate the compiled .mo files used by the application.

ADDING A LANGUAGE
=================

First, go to the ``config.py`` file and add your language in the same way as the other languages already available.

Activate your venv : ``source venv/bin/activate``

Then in your command prompt, go in your atlas path and use these commmands.

::

    # Extract your strings from html files | create or update .pot file
    pybabel extract -F babel.cfg -o messages.pot .
    
    # Create first translation, here in french (fr) | create .po file
    pybabel init -i messages.pot -d translations -l fr
  
    # To compile translations | create .mo file
    pybabel compile -d translations

ADDING STRINGS
==============

::

    # Extract your new strings from html files | create .pot file
    pybabel extract -F babel.cfg -o messages.pot .

    # Update strings changes
    pybabel update -i messages.pot -d translations

    # To compile translations | create .mo file
    pybabel compile -d translations

MODIFYING A STRING ALREADY IN .PO FILES
=======================================

Edit the ``.po`` file to change, then compile the translation files to generate to ``.mo`` files.

::

    # To compile translations | create .mo file
    pybabel compile -d translations


==========================
MULTILINGUAL MODULE : (FR)
==========================

Le module utilisé pour le multilingue est Flask-Babel (https://flask-babel.tkte.ch).

Vous pouvez activer ou désactiver ce module en changeant la valeur du paramètre ``MULTILINGUAL`` (``true`` ou ``false``) dans votre fichier ``config.py``.

Si vous le faites, vous devez renseigner ``DEFAULT_LANGUAGE`` avec votre clé de langue. Exemple ``'fr'`` pour le français. Assurez-vous que votre langue se trouve dans ``LANGUAGES`` dans votre fichier ``config.py``.

Voici les différentes commandes que vous pouvez utiliser pour ajouter une langue, ajouter du texte à traduire, ou mettre à jour les traductions.

Toutes les commandes doivent être utilisées dans le chemin de votre atlas dans une invite de commande.

Le fichier ``atlas/messages.pot`` est un template de traduction, généré automatiquement en parcourant les fichiers .html et .sample du projet.
Il est utilisé pour générer et ajouter les clés de traduction dans les fichiers .po de chaque langue.
Une fois que les fichiers .po ont été mis à jour manuellement, la commande finale va générer les fichier .mo compilés, utilisés par l'application.

AJOUTER UNE LANGUE
==================

Tout d'abord, allez dans le fichier ``config.py`` et ajoutez votre langue de la même manière que les autres langues déjà disponibles.

Ensuite, dans votre invite de commande, allez dans le chemin de votre atlas et utilisez les commandes suivantes.

::

    # Extraire vos nouvelles chaînes de caractères des fichiers html | créer un fichier .pot
    pybabel extract -F babel.cfg -o messages.pot .

    # Mise à jour des modifications des chaînes de caractères
    pybabel update -i messages.pot -d translations

    # Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d translations

AJOUTER DES CHAÎNES DE CARACTÈRES
=================================

::

    # Extraire vos nouvelles chaînes de caractères des fichiers html | créer un fichier .pot
    pybabel extract -F babel.cfg -o messages.pot .

    # Mise à jour des changements de chaînes
    pybabel update -i messages.pot -d translations

    # Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d translations
    
MODIFICATION D'UNE CHAÎNE DE CARACTÈRES DÉJÀ PRÉSENTE DANS LES FICHIERS .PO
===========================================================================

Modifier les fichiers ``.po`` souhaités dans le dossier ``atlas/translations/``, ensuite compilez les fichiers de traductions pour générer les fichiers ``.mo``.

::

    # Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d translations
