Configuration et customisation
##############################


Le fichier `atlas/configuration/config.py` contient l'ensemble des variables de configuration de l'atlas.

Celui-ci est par défaut assez minimaliste. Il peut être completé par toute une série d'autres paramètres pour personnaliser le comportement de l'application. L'ensemble des paramètres disponibles sont présents dans le ficher ``atlas/configuration/config.py.example``.

Après chaque modification de la configuration, relancer la commande ``sudo systemctl restart geonature-atlas`` pour qu'elles soient appliquées.

Customisation de l'application
==============================

En plus de la configuration, vous pouvez customiser l'application en modifiant et ajoutant des fichiers dans le répertoire ``static/custom/`` (css, templates, images).

L'atlas est fourni avec des variables CSS qui permettent de personnaliser facilement l'interface (changement des couleurs principales). Pour cela éditer les variables présentes dans le fichier ``static/custom/custom.css``. Les variables ``--main-color`` et ``second-color`` permettent de customiser l'atlas selon les couleurs de votre organism.

Vous pouvez aussi modifier ou ajouter des pages statiques de présentation, en plus de la page Présentation fournie par défaut. Pour cela, voir le paramètre ``STATIC_PAGES`` du fichier ``main/configuration/config.py``.

Customisation des textes et labels via la surcouche du multiligue
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Une grande partie des textes peuvent être personnalisés en changeant leur label via le mécanisme du multilingue (voir la documentation sur le multilingue).
Pour cela, identifiez dans les templates HTML la "clé" qui correspond au texte que vous voulez modifier.  Le fichier `atlas/messages.pot` contient l'ensemble des clés disponibles. Par exemple pour modifier le texte qui correspond à "Informations espèces" sur les fiches espèce : https://github.com/PnX-SI/GeoNature-atlas/blob/master/atlas/templates/speciesSheet/blocInfos.html#L11 , il faudra éditer la clé `species.info`.
Rendez-vous dans `static/custom/translations_override/<LA LANGUE QUE VOUS SOUHAITEZ>` et créer un fichier `messages.po`

Exemple : 

::
    # Fichier static/custom/translations_override/messages.po`
    msgid "species.infos"
    msgstr "Informations espèce"

Rendez vous dans le dossier `static/custom` et lancez : 

::
    pybabel compile -f -d translations_override

Relancez l'application :

::
    sudo systemctl restart geonature-atlas



Ajout de fiche "zonage"
^^^^^^^^^^^^^^^^^^^^^^

Par défaut l'atlas est configuré avec des fiches "commune". Il est possible d'ajouter d'autres types de zonage présent dans la table `ref_geo.bib_areas_type` de GeoNature.
Remplissez le paramètre `TYPE_TERRITOIRE_SHEET` avec le champs `type_code` de `ref_geo.bib_areas_type`
L'ajout de nouveaux type de zonage necessite de prendre en compte la question du floutage des données sensible : voir le `document  <degradation_donnees.rst>`_

Customisation de la carte
^^^^^^^^^^^^^^^^^^^^^^^^^

Paramétrage du style des données "floutées" en mode point
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
En mode point, il est possible de customiser l'affichage cartographique (modification de la couleur des points, modification de la légende) en éditant le fichier ``static/custom/maps-custom.js``. Par défaut l'affichage dissocie les données dégradées des données précises : voir `<degradation_donnees.rst>`_.

Paramétrage de l'affichage des données floutées en mode maille
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

La table `atlas.cor_sensitivity_area_type`, elle même construit à partir de la table GeoNature `gn_sensitivity.cor_sensitivity_area_type` permet de controler qu'elle type de zonage on affiche en fonction du niveau de sensibilité : voir `la documentation sur la sensibilité à ce sujet <./sensibilite_donnees.md>`_

Le paramètre `AFFICHAGE_COUCHES_MAP` permet de controler le style, le nom et l'affichage de chaque type de géométrie de floutage.
Par défault il vaut : 

::
    AFFICHAGE_COUCHES_MAP_DEFAULT = {
        "M1": {
            "label": "Maille 1km",
            "selected": True,
        },
        "COM": {
            "label": "Communes",
            "selected": True,
        },
        "M10": {
            "label": "Mailles 10 km",
            "selected": True,
        },
        "DEP": {
            "label": "Département",
            "selected": True,
        },
    }

Chaque clé de ce dictionnaire (`M1`, `M10`) doit correspondre à une entrée dans la table `atlas.cor_sensitivity_area_type`, si vous changez le contenu de cette table, vous devrez mettre ce paramètre en cohérence.
L'attribut `selected` permet de masquer par défaut un type de zonage (pour éviter les superposition et améliorer la lisibiliter de la carte).


Paramétrage des couches additionelles
"""""""""""""""""""""""""""""""""""""

Le paramètre `COUCHES_SIG`


TaxHub : le backoffice de GeoNature-Atlas
=========================================

Renseignement des informations lié à une espèces
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TaxHub permet de renseigner les informations liées à une espèce. C'est dans cette application qu'on décrit les attributs lié à une espèce et qu'on y associe des médias

Import de médias 
^^^^^^^^^^^^^^^^

TaxHub dispose de scripts permettant d'importer les médias des espèces depuis les photos libres de l'INPN (https://github.com/PnX-SI/TaxHub/tree/master/data/scripts/import_inpn_media) ou de Wikimedia (https://github.com/PnX-SI/TaxHub/tree/master/data/scripts/import_wikimedia_commons).


