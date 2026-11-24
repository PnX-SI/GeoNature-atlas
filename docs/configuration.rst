Configuration et customisation
##############################

Le fichier ``atlas/configuration/config.py`` contient l'ensemble des variables de configuration de GeoNature-atlas.

Celui-ci est par défaut assez minimaliste. Il peut être completé par toute une série d'autres paramètres pour personnaliser le comportement de l'application. L'ensemble des paramètres disponibles sont présents dans le ficher ``atlas/configuration/config.py.example``.

Après chaque modification de la configuration, relancer la commande ``sudo systemctl restart geonature-atlas`` pour qu'elles soient appliquées.

Cache des pages et webservices
==============================

GeoNature-atlas met en cache certaines pages et les données qu'elles affichent :

* les fiches **Espèce**, **Territoire**, **Rang taxonomique** et **Groupe** ;
* les fiches **Organisme**, si le module correspondant est activé ;
* les listes d'espèces, la galerie photo, les statistiques générales et les graphiques des fiches Territoire.

Les résultats de recherche et les observations affichées sur les cartes ne sont pas mis en cache.

Le paramètre ``CACHE_TIMEOUT`` indique, en secondes, combien de temps une donnée reste en cache.
Il est utilisé par défaut ; le paramètre ``CACHE_DEFAULT_TIMEOUT`` de Flask-Caching, s'il est
défini, le remplace. Avec le réglage par défaut ``SimpleCache``, le cache est conservé en mémoire
et vidé au redémarrage du service.

.. note::

   Après le rafraîchissement des vues matérialisées, les pages déjà présentes dans le cache peuvent
   encore afficher les anciennes données jusqu'à l'expiration de ``CACHE_TIMEOUT``. Pour voir les
   nouvelles données immédiatement, redémarrez l'Atlas : avec ``SimpleCache``, cela vide le cache.
   Sans redémarrage, les données se mettront à jour à l'expiration du cache. Les pages et données
   non mises en cache utilisent les nouvelles vues dès la requête suivante. Avec un autre type de
   cache, la purge du cache dépend du type de cache utilisé.

Les principaux paramètres sont :

* ``CACHE_TYPE`` : type de cache ; l'Atlas utilise ``SimpleCache`` par défaut ;
* ``CACHE_TIMEOUT`` ou ``CACHE_DEFAULT_TIMEOUT`` : durée de conservation en secondes ;
* ``CACHE_THRESHOLD`` : nombre maximal d'entrées conservées par ``SimpleCache`` (500 par défaut).

Pour désactiver complètement le cache, ajoutez ``CACHE_TYPE = "NullCache"`` dans
``config.py``, puis redémarrez l'Atlas. Les routes configurées pour utiliser le cache continueront
de fonctionner, mais leurs réponses ne seront plus conservées.

D'autres types de cache et paramètres sont disponibles. Consultez la
`documentation de Flask-Caching <https://flask-caching.readthedocs.io/en/latest/>`_ pour les
détails. Un exemple de configuration est fourni dans ``atlas/configuration/config.py.example``.

Configuration des données d'observations présentes dans l'atlas
===============================================================

Dans un contexte où GeoNature-atlas est branché sur une base de données GeoNature, l'application prend par défaut toutes les données dans la table ``gn_synthese.synthese`` (en excluant par défaut les données d'absence et les données sensibles non diffusables). Il est possible de filtrer les données que l'on souhaite voir dans GeoNature-atlas en fournissant une vue que l'on aura préalablement créé dans GeoNature. Cette vue doit être dans le schéma ``gn_synthese`` de la base de données de GeoNature(voir https://github.com/PnX-SI/GeoNature-atlas/issues/749). Remplissez alors le paramètre ``observation_data_source`` du fichier ``settings.ini`` avec le nom de la vue que vous avez créé et relancer le script d'installation de la base de données de GeoNature-atlas (``install_db.sh``).

.. note::
    
La script de création de la base de données exclut automatiquement les données d'absence (statut_observation != 'Pr') et les données ou le niveau de sensibilité = "Aucune diffusion".



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
