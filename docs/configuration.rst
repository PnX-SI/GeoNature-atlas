Configuration et customisation
##############################

Le fichier ``atlas/configuration/config.py`` contient l'ensemble des variables de configuration de GeoNature-atlas.

Celui-ci est par défaut assez minimaliste. Il peut être completé par toute une série d'autres paramètres pour personnaliser le comportement de l'application. L'ensemble des paramètres disponibles sont présents dans le ficher ``atlas/configuration/config.py.example``.

Après chaque modification de la configuration, relancer la commande ``sudo systemctl restart geonature-atlas`` pour qu'elles soient appliquées.

Configuration des données d'observations présentes dans l'atlas
===============================================================

Dans un contexte où GeoNature-atlas est branché sur une base de données GeoNature, l'application prend par défaut toutes les données présentes dans la table ``gn_synthese.synthese``. . Il est possible de filtrer les données que l'on souhaite voir dans GeoNature-atlas en fournissant une vue que l'on aura préalablement créé dans GeoNature. Cette vue doit être dans le schéma ``gn_synthese`` de la base de données de GeoNature, faire un SELECT sur la table ``gn_synthese.synthese`` et y ajouter un WHERE pour en filtrer les données souhaitées (voir https://github.com/PnX-SI/GeoNature-atlas/issues/749). 

.. note::
    
La script de création de la base de données exclue automatiquement  les données d'absence (statut_observation != 'Pr') et les donnée et les données ou le niveau de sensibilité = "Aucune diffusion".

Remplissez alors le paramètre ``observation_data_source`` du fichier ``settings.ini`` avec le nom de la vue que vous avez créé et relancer le script d'installation de la base de données de GeoNature-atlas (``install_db.sh``).

Customisation de l'application
==============================

En plus de la configuration, vous pouvez customiser l'application en modifiant et ajoutant des fichiers dans le répertoire ``static/custom/`` (css, templates, images).
Les pictos illustrant les espèces patrimoniales, protégées et menacées sont modifiables en changeant les images présentes dans le répertoire ``custom/images``.

L'atlas est fourni avec des variables CSS qui permettent de personnaliser facilement l'interface (changement des couleurs principales). Pour cela surcoucher les classes CSS dans le fichier ``static/custom/custom.css``. 

Utilisez les paramètres ``TEMPLATE_MAIN_COLOR`` et ``TEMPLATE_SECOND_COLOR`` dans ``config.py`` pour définir les couleurs principales et secondaire que vous souhaitez.

Vous pouvez aussi modifier ou ajouter des pages statiques de présentation, en plus de la page "Présentation" fournie par défaut. Pour cela, voir le paramètre ``STATIC_PAGES`` du fichier ``atlas/configuration/config.py``.

Customisation des textes et labels via la surcouche du multiligue
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Une grande partie des textes peuvent être personnalisés en changeant leur label via le mécanisme du multilingue (voir la documentation sur le multilingue).
Pour cela, identifiez dans les templates HTML la "clé" qui correspond au texte que vous voulez modifier. Le fichier `atlas/messages.pot` contient l'ensemble des clés disponibles. Par exemple pour modifier le texte qui correspond à "Informations espèces" sur les fiches espèce : https://github.com/PnX-SI/GeoNature-atlas/blob/master/atlas/templates/speciesSheet/blocInfos.html#L11 , il faudra éditer la clé ``species.info``.
Rendez-vous dans ``static/custom/translations_override/<LA LANGUE QUE VOUS SOUHAITEZ>`` et créer un fichier ``messages.po``

Exemple : 

::

    # Fichier static/custom/translations_override/messages.po`
    msgid "species.infos"
    msgstr "Informations espèce"

Rendez vous ensuite dans le dossier ``static/custom`` et lancez : 

::

    make compile_messages

Relancez l'application :

::

    sudo systemctl restart geonature-atlas



Ajout de fiches "zonage"
^^^^^^^^^^^^^^^^^^^^^^^

Par défaut l'atlas est configuré avec des fiches "commune" uniquement. Il est possible d'ajouter d'autres types de zonage présents dans la table ``ref_geo.bib_areas_type`` de GeoNature.
Remplissez le paramètre ``TYPE_TERRITOIRE_SHEET`` avec le champs ``type_code`` de ``ref_geo.bib_areas_type``.
L'ajout de nouveaux types de zonage nécessite de prendre en compte la question du floutage des données sensibles : voir la `documentation <./sensibilite_donnees.md>`_

Customisation de la carte
^^^^^^^^^^^^^^^^^^^^^^^^^

Paramétrage du style des données "floutées" en mode point
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

En mode point, il est possible de customiser l'affichage cartographique (modification de la couleur des points, modification de la légende) en éditant le fichier ``static/custom/maps-custom.js``. Par défaut l'affichage dissocie les données sensibles (dégradées) des données précises : voir `<./sensibilite_donnees.md>`_.

Paramétrage de l'affichage des données floutées en mode maille
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

La table de GeoNature ``gn_sensitivity.cor_sensitivity_area_type`` permet de controler quel type de zonage on affiche en fonction du niveau de sensibilité : voir `la documentation sur la sensibilité à ce sujet <./sensibilite_donnees.md>`_
Par défaut une seule couche d'observations est cochée dans le sélecteur de couches : c'est la couche des observations les moins sensibles (le plus petit niveau d'affichage)

Paramétrage des couches additionelles
"""""""""""""""""""""""""""""""""""""

Le paramètre ``COUCHES_SIG``

TaxHub : le backoffice de GeoNature-atlas
=========================================

Renseignement des informations liées à une espèce
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TaxHub permet de renseigner les informations liées à une espèce. C'est dans cette application qu'on décrit les attributs lié à une espèce et qu'on y associe des médias.

Import de médias 
^^^^^^^^^^^^^^^^

TaxHub dispose de scripts permettant d'importer les médias des espèces depuis les photos libres de l'INPN ou de Wikimedia (https://taxhub.readthedocs.io/fr/latest/manuel-administrateur.html#commandes).
