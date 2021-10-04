
=====================
MULTILINGUAL MODULE : (EN)
=====================

Multilingual module here use flask-babel, here is the documentation:
https://flask-babel.tkte.ch/

You can activate or deactivate this module by modyfying MULTILINGUAL to false in your config.py file.
If you do so, you have to put BABEL_DEFAULT_LOCALE to your languge key : example 'fr' for french. Na dbe sure that your language is in LANGUAGES in your config.py file.

Here is the different commands you can use for adding a language, adding text to translate, or update translations.
All the commands shoule be use in your atlas path in a command prompt.


-------

ADDING A LANGUAGE: 
=========

First, go to the config.py file and add your language in the same way as the other languages already present.
Activate your venv : source venv/bin/activate
Then in your command prompt, go in your atlas path and use this commmands.


::

    #Extract your strings from html files | create or update .pot file
    pybabel extract -F babel.cfg -o messages.pot .
    
    #Create first translation, here in french (fr) | create .po file
    pybabel init -i messages.pot -d translations -l fr
  
    #To compile translations | create .mo file
    pybabel compile -d translations


ADDING STRINGS:
=========
::

    #Extract your new strings from html files | create .pot file
    pybabel extract -F babel.cfg -o messages.pot .

    #Update strings changes
    pybabel update -i messages.pot -d translations

    #To compile translations | create .mo file
    pybabel compile -d translations



MODIFYING A STRING ALREADY IN .PO FILES
=========
::

    #To compile translations | create .mo file
    pybabel compile -d translations


=====================
MULTILINGUAL MODULE : (FR)
=====================

Module multilingue ici utiliser flask-babel, voici la documentation :
https://flask-babel.tkte.ch/

Vous pouvez activer ou désactiver ce module en modyfiant MULTILINGUAL à false dans votre fichier config.py.
Si vous le faites, vous devez mettre BABEL_DEFAULT_LOCALE à votre clé de langue : exemple 'fr' pour le français. Assurez-vous que votre langue se trouve dans LANGUAGES dans votre fichier config.py.

Voici les différentes commandes que vous pouvez utiliser pour ajouter une langue, ajouter du texte à traduire, ou mettre à jour les traductions.
Toutes les commandes doivent être utilisées dans le chemin de votre atlas dans une invite de commande.

-------

AJOUTER UNE LANGUE : 
=========

Tout d'abord, allez dans le fichier config.py et ajoutez votre langue de la même manière que les autres langues déjà présentes.
Ensuite, dans votre invite de commande, allez dans le chemin de votre atlas et utilisez les commandes suivantes.


::

    #Extraire vos nouvelles chaînes de caractères des fichiers html | créer un fichier .pot
    pybabel extract -F babel.cfg -o messages.pot .

    #Mise à jour des modifications des chaînes de caractères
    pybabel update -i messages.pot -d translations

    #Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d translations


AJOUTER DES CHAÎNES DE CARACTÈRES :
=========
::

    #Extraire vos nouvelles chaînes de caractères des fichiers html | créer un fichier .pot
    pybabel extract -F babel.cfg -o messages.pot .

    #Mise à jour des changements de chaînes
    pybabel update -i messages.pot -d translations

    #Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d traductions
    
MODIFICATION D'UNE CHAÎNE DE CARACTÈRES DÉJÀ PRÉSENTE DANS LES FICHIERS .PO
=========
::

    #Pour compiler les traductions | créer un fichier .mo
    pybabel compile -d traductions

