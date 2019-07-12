============
INSTALLATION
============
.. image:: http://geonature.fr/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr

-----

Prérequis
=========

Application développée et installée sur un serveur Debian 7 ou 8.

Ce serveur doit aussi disposer de :

- unzip (apt-get install unzip)
- sudo (apt-get install sudo)
- un utilisateur (``monuser`` dans cette documentation) appartenant au groupe ``sudo`` (pour pouvoire bénéficier des droits d'administrateur)

:notes:

    Si sudo n'est pas installé par défaut, voir https://www.privateinternetaccess.com/forum/discussion/18063/debian-8-1-0-jessie-sudo-fix-not-installed-by-default

:notes:

    GeoNature-atlas est susceptible de fonctionner sur d'autres OS (comme Ubuntu par exemple) mais cela n'a pas été testé.


Installation de l'environnement logiciel
========================================

Le script ``install_env.sh`` va automatiquement installer les outils nécessaires à l'application si ils ne sont pas déjà sur le serveur :

- PostgreSQL 9.3+
- PostGIS 2
- Apache 2
- Python 2.7

Le script ``install_app.sh`` va préparer l'application et installer les dépendances listées dans le fichier `requirements.txt <https://github.com/PnX-SI/GeoNature-atlas/blob/master/requirements.txt>`_.

**1. Mettre à jour les sources list**

Ces opérations doivent être faites en tant qu'administrateur (en sudo ou avec l'utilisateur ``root``) :

::

    sudo echo "#" >> /etc/apt/sources.list
    sudo echo "#Ajout pour GeoNature-atlas" >> /etc/apt/sources.list
    sudo echo "deb http://httpredir.debian.org/debian jessie main" >> /etc/apt/sources.list
    sudo apt-get update

:notes:

    Cet exemple est basé sur une Debian 8. A adapter selon votre OS.

**2. Récupérez la dernière version (X.Y.Z à remplacer par le numéro de version) de GeoNature-atlas sur le dépot (https://github.com/PnX-SI/GeoNature-atlas/releases)**

Ces opérations doivent être faites avec l'utilisateur courant (autre que ``root``), ``monuser`` dans l'exemple :

::

    cd /home/monuser
    wget https://github.com/PnX-SI/GeoNature-atlas/archive/X.Y.Z.zip


:notes:

    Si la commande ``wget`` renvoie une erreur liée au certificat, installez le paquet ``ca-certificates`` (``sudo apt-get install ca-certificates``) puis relancer la commande ``wget`` ci-dessus.

Dézippez l'archive :

::

    unzip X.Y.Z.zip

Vous pouvez renommer le dossier qui contient l'application (dans un dossier ``/home/monuser/atlas/`` par exemple) :

::

    mv GeoNature-atlas-X.Y.Z atlas

**3. Placez-vous dans le dossier qui contient l'application et lancez l'installation de l'environnement serveur :**

Cela installera les logiciels nécessaires au fonctionnement de l'application

::

    cd /home/monuser/atlas
    ./install_env.sh



Installation de la base de données
==================================

Modifiez le fichier de configuration de la BDD et de son installation automatique ``atlas/configuration/settings.ini``.


:notes:

    Suivez bien les indications en commentaire dans ce fichier

:notes:

    Attention à ne pas mettre de 'quote' dans les valeurs, même pour les chaines de caractères.

:notes:

    Le script d'installation automatique de la BDD ne fonctionne que pour une installation de celle-ci en localhost car la création d'une BDD recquiert des droits non disponibles depuis un autre serveur. Dans le cas d'une BDD distante, adaptez les commandes du fichier `install_db.sh` en les executant une par une.


L'application se base entièrement sur des vues matérialisées. Par défaut, celles-ci sont proposées pour requêter les données dans une BDD GeoNature.

.. image :: images/geonature-atlas-schema-02.jpg

Cela laisse donc la possibilité de la connecter à une autre BDD en adaptant la vue ``atlas.vm_observations`` dans ``data/atlas.sql`` (en respectant impérativement les noms de champs).

.. image :: images/geonature-atlas-schema-01.jpg

Plus de détails sur les différentes vues matérialisées dans le fichier `<vues_materialisees_maj.rst>`_  qui indique aussi comment automatiser leur mise à jour.

Vous y trouverez aussi un exemple d'adaptation de la vue ``atlas.vm_observations`` basé sur une BDD SICEN.

Par ailleurs, si vous n'utilisez pas GeoNature, il vous faut installer TaxHub (https://github.com/PnX-SI/TaxHub/) ou au moins sa BDD, pour gérer les attributs (description, commentaire, milieu et chorologie) ainsi que les médias rattachés à chaque espèce (photos, videos, audios et articles)

L'installation du schéma `taxonomie` de TaxHub dans la BDD de l'atlas peut se faire automatiquement lors de l'installation de la BDD avec le paramètre ``install_taxonomie=true``.

A noter aussi que si vous ne connectez pas l'atlas à une BDD GeoNature(``geonature_source=false``), une table exemple ``synthese.syntheseff`` comprenant 2 observations est créée. A vous d'adapter les vues après l'installation pour les connecter à vos données sources.

Lancez le fichier fichier d'installation de la base de données en sudo :

::

    sudo ./install_db.sh

:notes:

    Vous pouvez consulter le log de cette installation de la base dans ``log/install_db.log`` et vérifier qu'aucune erreur n'est intervenue.

Vous pouvez alors modifier les vues, notamment ``atlas.vm_observations`` pour les adapter à votre contexte (ajouter les données partenaires, filtrer les espèces, limiter à un rang taxonomique...) ou le connecter à une autre BDD source (en important les données ou en s'y connectant en FDW).

Le script ``install_db.sh`` supprime la BDD de GeoNature-atlas et la recréer entièrement.

Si vous voulez adapter le contenu des vues matérialisées, vous pouvez modifier le fichier ``data/atlas.sql`` puis relancer ce script global de la BDD.

Si vous souhaitez uniquement recréer la vue ``atlas.vm_observations`` et les 6 autres vues qui en dépendent vous pouvez utiliser le script ``data/update_vm_observations.sql``.


Installtion de l'application
============================

**Lancez l'installation automatique de l'application :**

::

    ./install_app.sh

Configuration de l'application
==============================

Editer le fichier de configuration ``atlas/configuration/config.py``.

- Vérifier que la variable 'database_connection' contient les bonnes informations de connexion à la base
- Renseignez l'URL de l'application à partir de la racine du serveur WEB ('/atlas' ou '' par exemple)
- Renseignez les autres paramètres selon votre contexte
- Rechargez le serveur Web Gunicorn pour que les modifications soient prises en compte (``sudo supervisorctl reload``)


Customisation de l'application
==============================

En plus de la configuration, vous pouvez customiser l'application en modifiant et ajoutant des fichiers dans le répertoire ``static/custom/`` (css, templates, images).

Vous pouvez aussi modifier ou ajouter des pages statiques de présentation, en plus de la page Présentation fournie par défaut. Pour cela, voir le paramètre ``STATIC_PAGES`` du fichier ``main/configuration/config.py``


Configuration d'Apache
======================

Créez un virtualhost pour l'atlas :

::

    sudo nano /etc/apache2/sites-available/atlas.conf

Pour rendre l'application consultable comme un sous répertoire du serveur  (http://monURL/atlas par exemple).
Copiez/collez-y ces lignes en renseignant le bon port :
::

    # Configuration GeoNature-atlas
    RewriteEngine  on
    <Location /atlas>
        ProxyPass  http://127.0.0.1:8080
        ProxyPassReverse  http://127.0.0.1:8080
    </Location>
    #FIN Configuration GeoNature-atlas

Si l'atlas doit se trouver à la racine du serveur copiez/coller ces lignes (NB les '/' à la fin des ProxyPass et ProxPassReverse)
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
	sudo a2enmod rewrite
        sudo apache2ctl restart


Activez le virtualhost puis redémarrez Apache :

::

    sudo a2ensite atlas
    sudo apachectl restart

:notes:

    En cas d'erreur, les logs serveurs ne sont pas au niveau d'Apache (serveur proxy) mais de Gunicorn (serveur HTTP) dans ``/tmp/errors_atlas.log``


Mise à jour de l'application
============================

- Télécharger puis dézipper la nouvelle version de l'atlas à installer dans ``/home/monuser``.
- Renommer l'ancienne version de l'atlas puis la nouvelle version, en lui donnant le nom du répertoire précédemment utilisé si vous voulez éviter de devoir modifier votre configuration Apache.
- Vous pouvez aussi créer un nouveau répertoire pour l'application dans ``home/monuser/`` et cloner la version souhaitée depuis le dépot Github (``git clone``).

:notes:

    A la racine de l'application, un fichier ``VERSION`` permet de savoir quelle version est installée.

- Copier ``atlas/configuration/settings.ini`` et ``atlas/configuration/config.py`` depuis l'ancienne version vers la nouvelle pour récupérer vos paramètres de configuration :

::

    cd atlas-nouvelle-version
    cp ../VERSION-PRECEDENTE/atlas/configuration/settings.ini atlas/configuration/settings.ini
    cp ../VERSION-PRECEDENTE/atlas/configuration/config.py atlas/configuration/config.py

- Copier le contenu du répertoire ``static/custom/`` depuis l'ancienne version vers la nouvelle pour récupérer toute votre customisation (CSS, templates, images...) :

::

    cp -aR ../VERSION-PRECEDENTE/static/custom/ ./static


Attention à bien lire les notes de chaque version, qui peuvent indiquer des opérations spécifiques à faire, notamment des nouveaux paramètres à ajouter dans votre configuration et/ou des modifications à appliquer dans la BDD.

- Relancez l'installation automatique de l'application :

::

    ./install_app.sh


Mise à jour des couches de référence
====================================

Limite du territoire ou communes.

Voir les parties concernées dans `install_db.sh <../install_db.sh#L65-L88>`_.


Accéder à votre BDD
===================

Par défaut un serveur PostgreSQL n'écoute et n'autorise des connexions que du serveur lui-même (localhost).

Si vous souhaitez vous y connecter depuis un autre serveur ou PC, connectez-vous en SSH sur le serveur de la BDD de l'atlas, puis éditez les fichiers de configuration de PostgreSQL.

Pour écouter toutes les IP, éditez le fichier ``postgresql.conf`` :

::

    sudo nano /etc/postgresql/9.4/main/postgresql.conf

Remplacez ``listen_adress = 'localhost'`` par  ``listen_adress = '*'``. Ne pas oublier de décommenter la ligne (enlever le ``#``).

Pour définir les IP qui peuvent se connecter au serveur PostgreSQL, éditez le fichier ``pg_hba.conf``

::

    sudo nano /etc/postgresql/9.4/main/pg_hba.conf

Si vous souhaitez définir des IP qui peuvent se connecter à la BDD, sous la ligne ``# IPv4 local connections:``, rajouter :

::

    host    all     all     MON_IP_A_REMPLACER/0        md5  #Pour donner accès à une IP

ou si vous souhaitez y donner accès depuis n'importe quelle IP, rajouter :

::

    host    all     all     0.0.0.0/0        md5

Redémarrez PostgreSQL pour que ces modifications soient prises en compte :

::

    sudo /etc/init.d/postgresql restart

Si votre atlas se connecte à une BDD mère distante qui contient les données sources (GeoNature, SICEN...), vous devez autoriser le serveur de l'atlas à s'y connecter.

Connectez-vous en SSH sur le serveur hébergeant la BDD source, puis éditez la configuration de PostgreSQL :

::

    sudo nano /etc/postgresql/9.4/main/pg_hba.conf

Rajouter cette ligne à la fin du fichier (en remplacant IP_DE_LA_BDD_ATLAS par son adresse IP) :

::

    host     all            all             IP_DE_LA_BDD_ATLAS/32       md5

Redémarrez PostgreSQL pour que ces modifications soient prises en compte :

::

    sudo /etc/init.d/postgresql restart


Développement
=============

**Technologies**

.. image :: images/dev-technologies.png

**Architecture du code (MVC)**

.. image :: images/dev-architecture-code-mvc.png

**Architecture de l'application**

.. image :: images/dev-architecture-application.png

Des données sont renvoyées aux templates par l'ORM, d'autres le sont sous forme d'API (fichiers JSON chargés en AJAX) pour charger certaines pages plus rapidement (observations sur les fiches espèces et auto-complétion de la recherche) :

Pour en savoir plus, consultez le document `<vues_materialisees_maj.rst>`_ ainsi que le rapport de stage de Théo Lechemia (https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/2016-09-30-rapport_stage_Theo-Lechemia.pdf) ou sa présentation (https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/2016-09-soutenance-Theo-Lechemia.pdf)
