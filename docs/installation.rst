============
Installation
============


Prérequis
=========

Application installable sur un serveur Debian 12 et 13.

Ce serveur doit aussi disposer de :

- unzip (apt-get install unzip)
- sudo (apt-get install sudo)
- un utilisateur (``whoami`` dans cette documentation - ``whoami`` est une variable d'environnement Linux qui désigne l'utilisateur courant) appartenant au groupe ``sudo`` (pour pouvoir bénéficier des droits d'administrateur)

.. note::
    GeoNature-atlas est susceptible de fonctionner sur d'autres OS (comme Ubuntu par exemple) mais cela n'a pas été testé.



**1. Récupérez la dernière version (X.Y.Z à remplacer par le numéro de version) de GeoNature-atlas (https://github.com/PnX-SI/GeoNature-atlas/releases)**

Ces opérations doivent être faites avec l'utilisateur courant (autre que ``root``), ``whoami`` dans l'exemple :

::

    cd /home/`whoami`
    wget https://github.com/PnX-SI/GeoNature-atlas/archive/X.Y.Z.zip


.. note::

    Si la commande ``wget`` renvoie une erreur liée au certificat, installez le paquet ``ca-certificates`` (``sudo apt-get install ca-certificates``) puis relancer la commande ``wget`` ci-dessus.

Dézippez l'archive et la supprimer:

::

    unzip X.Y.Z.zip
    rm X.Y.Z.zip

Vous pouvez renommer le dossier qui contient l'application (dans un dossier ``/home/`whoami`/atlas/`` par exemple) :

::

    mv GeoNature-atlas-X.Y.Z atlas
    cd atlas

**2. Installation de l'environnement logiciel**

Le script ``install_env.sh`` va automatiquement installer les outils nécessaires à l'application si ils ne sont pas déjà sur le serveur :

- PostgreSQL
- PostGIS
- Apache 2
- Python 3 et GDAL

Lancer le script :

::

    cd /home/`whoami`/atlas/install/
    ./install_env.sh


**3. Installation de la base de données**

Faites une copie du fichier de configuration``atlas/configuration/settings.ini.sample`` puis modifiez-le.

Si vous souhaitez installer la base de données de l'atlas à partir d'une autre BDD que celle de GeoNature, suivez la  `documentation suivante <install_db_without_gn.rst>`_

::

    cd /home/`whoami`/atlas/atlas/configuration
    cp settings.ini.sample settings.ini
    nano settings.ini



* Suivez bien les indications en commentaire dans ce fichier.

* Attention à ne pas mettre de 'quote' dans les valeurs, même pour les chaines de caractères.

* Dans le cas où vous souhaitez connecter l'atlas à une BDD distante de GeoNature v2, il faut au préalable créer un utilisateur spécifique pour l'atlas dans cette dernière (lecture seule). Pour cela se connecter en SSH au serveur hébergeant la BDD mère de GeoNature v2 et lancez les commandes suivantes en les adaptant. Faire ensuite correspondre avec les paramètres concernés dans le fichier ``settings.ini`` (``atlas_source_user`` et ``atlas_source_pass``) :

  ::

    sudo su - postgres
    psql
    CREATE USER geonatatlas WITH ENCRYPTED PASSWORD 'monpassachanger';
    \c geonature2db
    GRANT USAGE ON SCHEMA gn_synthese, ref_geo, ref_nomenclatures, taxonomie, utilisateurs, gn_meta, gn_sensitivity TO geonatatlas;
    GRANT SELECT ON ALL TABLES IN SCHEMA gn_synthese, ref_geo, ref_nomenclatures, taxonomie, utilisateurs, gn_meta, gn_sensitivity TO geonatatlas;
    \q
    exit


**Attention** . Par défaut le ``ref_geo`` contient l'ensemble des communes de France, ce qui ralentit fortement l'installation.

Pour accelérer l'installation, vous pouvez "désactiver" certains zonages du ``ref_geo``, dont vous ne vous servez pas. Voir l'exemple de requête ci-dessous :

::

    update ref_geo.l_areas 
    set enable = false where not st_intersects(geom,  
        (
        select st_union(geom)
        from ref_geo.l_areas la 
        where la.id_type = 26 and area_code in ('38', '05', '74')
        )
    )

.. note::

    Le script d'installation automatique de la BDD ne fonctionne que pour une installation de celle-ci sur le même serveur que l'application (``localhost``) car la création d'une BDD requiert des droits non disponibles depuis un autre serveur. Dans le cas d'une BDD distante, adaptez les commandes du fichier ``install_db.sh`` en les exécutant une par une.

L'application se base entièrement sur des vues matérialisées. Par défaut, celles-ci sont proposées pour requêter les données dans une BDD GeoNature.

.. image :: images/geonature-atlas-schema-02.jpg

Cela laisse donc la possibilité de la connecter à une autre BDD en adaptant. Vous pouvez fournir en entrée une vue ou une table (à renseigner dans le paramètre ``observation_data_source``) qui doit avec la même structure pour construire la vue ``atlas.vm_observations`` dans ``data/atlas/05.vm_observations.sql`` (en respectant impérativement les noms de champs). Le script d'installation fourni toutes les tables nécessaires lorsque l'on souhaite installer l'application sans GeoNature (voir ``data/without_gn2/without_geonature.sql``).

.. image :: images/geonature-atlas-schema-01.jpg


**3.1 Installation de la base de données de GeoNature-atlas**

Lancez le fichier d'installation de la base de données :

::

    cd /home/`whoami`/atlas/install/
    ./install_db.sh


.. note::

    Vous pouvez consulter le log de cette installation de la base de données dans ``log/install_db.log`` et vérifier qu'aucune erreur ne s'est produite.

Pour filtrer les données provenant de GeoNature (intégrer ou non les données partenaires, limiter le territoire, filtrer les espèces, limiter à un rang taxonomique...), vous pouvez créer une vue dans votre BDD GeoNature basée sur la table ``gn_synthese.synthese`` et la renseigner dans le paramètre ``observation_data_source``. Vous pouvez aussi connecter GeoNature-atlas à une autre BDD source (en important les données ou en s'y connectant en FDW).

.. tip::

    Un mécanisme de dégradation des données sensibles est fourni par défaut dans GeoNature-atlas, voir la documentation à ce sujet : `<sensibilite_donnees.md>`_

**4. Installation de l'application**

Lancez l'installation automatique de l'application :

::

    cd /home/`whoami`/atlas/install/
    ./install_app.sh



Configuration de l'application
==============================

Le fichier de configuration central de l'application est ``atlas/configuration/config.py``. Celui-ci est par défaut assez minimaliste. Il peut être completé par toute une série d'autres paramètres pour personnaliser le comportement de l'application. L'ensemble des paramètres disponibles sont présents dans le ficher ``atlas/configuration/config.py.example``.

- Vérifier que la variable ``SQLALCHEMY_DATABASE_URI`` contient les bonnes informations de connexion à la BDD
- Renseignez l'URL de l'application à partir de la racine du serveur WEB ('/atlas' ou '' par exemple)
- Renseignez les autres paramètres selon votre contexte

Après chaque modification de la configuration, relancer la commande ``sudo systemctl restart geonature-atlas`` pour qu'elles soient appliquées.


Configuration d'Apache
======================

Créez un virtualhost pour l'atlas :

::

    sudo nano /etc/apache2/sites-available/atlas.conf

Pour rendre l'application consultable comme un sous répertoire du serveur (http://monURL/atlas par exemple), copiez/collez-y ces lignes en renseignant le bon port :

::

    # Configuration GeoNature-atlas
    <Location /atlas>
        ProxyPass  http://127.0.0.1:8080/atlas
        ProxyPassReverse  http://127.0.0.1:8080/atlas
    </Location>
    #FIN Configuration GeoNature-atlas

Si l'atlas doit se trouver à la racine du serveur, copiez/coller ces lignes (NB les '/' à la fin des ProxyPass et ProxPassReverse)

::

	<Location />
   	    ProxyPass http://127.0.0.1:8080/
	    ProxyPassReverse http://127.0.0.1:8080/
 	 </Location>

Si l'atlas est associé à un domaine, ajoutez cette ligne au début du fichier :

::

    ServerName mondomaine.fr

* Activer les modules et redémarrer Apache :

::

    sudo a2enmod proxy
    sudo a2enmod proxy_http
    sudo apache2ctl restart

* Activez le virtualhost puis redémarrez Apache :

::

    sudo a2ensite atlas
    sudo apachectl restart


.. note::

    En cas d'erreur, les logs serveurs ne sont pas au niveau d'Apache (serveur proxy) mais de Gunicorn (serveur HTTP) dans ``/var/log/geonature-atlas.log``


Mise à jour de l'application
============================

- Télécharger puis dézipper la nouvelle version de l'atlas.

::

    cd /home/`whoami`

    wget https://github.com/PnX-SI/GeoNature-atlas/archive/X.Y.Z.zip
    unzip X.Y.Z
    rm X.Y.Z

- Renommer l'ancienne version de l'atlas puis la nouvelle version.

::

    mv /home/`whoami`/atlas/ /home/`whoami`/atlas_old/
    mv GeoNature-atlas-X.Y.Z /home/`whoami`/atlas/

- Copier ``atlas/configuration/settings.ini`` et ``atlas/configuration/config.py`` depuis l'ancienne version vers la nouvelle pour récupérer vos paramètres de configuration :

::

    cd atlas
    cp ../atlas_old/atlas/configuration/settings.ini atlas/configuration/settings.ini
    cp ../atlas_old/atlas/configuration/config.py atlas/configuration/config.py

- Copier le contenu du répertoire ``static/custom/`` depuis l'ancienne version vers la nouvelle pour récupérer toute votre customisation (CSS, templates, images...) :

::

    cp -aR ../atlas_old/atlas/static/custom/ ./atlas/static


Attention à bien lire les notes de chaque version, qui peuvent indiquer des opérations spécifiques à faire, notamment des nouveaux paramètres à ajouter dans votre configuration.

- Relancez l'installation automatique de l'application :

::
    
    cd install
    ./install_app.sh

Mise à jour de la base de données
=================================

Lancer le script ``./install/install_db.sh`` pour mettre à jour la base de données de l'atlas.


.. danger::
    Le paramètre ``ATLAS_DROP_SCHEMA`` doit être à ``true`` pour réinstaller la base de données.
    Ce script va supprimer puis recréer le schéma ``atlas``. Ne mettez aucune table ou vue spécifique dans ce schéma.



Développement
=============

Lire le fichier ``CONTRIBUTING.md``.


**Lancement de l'application**

Depuis la racine du dépôt:

::

    source venv/bin/activate
    flask run

Pour changer le port de l'application, désampler le fichier ``atlas/.flaskenv.sample`` et éditer la variable ``FLASK_RUN_PORT``.

**Technologies**

.. image :: images/dev-technologies.png

**Architecture du code (MVC)**

.. image :: images/dev-architecture-code-mvc.png

**Architecture de l'application**

.. image :: images/dev-architecture-application.png

Des données sont renvoyées aux templates par l'ORM, d'autres le sont sous forme d'API (fichiers JSON chargés en AJAX) pour charger certaines pages plus rapidement (observations sur les fiches espèces et auto-complétion de la recherche) :

Pour en savoir plus, consultez le rapport de stage de Théo Lechemia (https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/files/2016-09-30-rapport_stage_Theo-Lechemia.pdf) ou sa présentation (https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/files/2016-09-soutenance-Theo-Lechemia.pdf)
