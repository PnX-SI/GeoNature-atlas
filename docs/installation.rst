============
INSTALLATION
============
.. image:: http://pnecrins.github.io/GeoNature/img/logo-pne.jpg
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


Installation de l'environnement et de l'application
===================================================

Le script ``install_env.sh`` va automatiquement installer les outils nécessaire à l'application si ils ne sont pas déjà installés sur le serveur : 

- PostgreSQL 9.3 mini
- PostGIS 2.x
- Apache 2
- Python 2.7

Il va aussi installer les dépendances listées dans le fichier `requirements.txt <https://github.com/PnEcrins/GeoNature-atlas/blob/master/requirements.txt>`_.

**1. Mettre à jour les sources list**

Ces opérations doivent être faites avec l'utilisateur ``root`` (ou en sudo) :

::

    su root
    echo "#" >> /etc/apt/sources.list
    echo "#Ajout pour GeoNature-atlas" >> /etc/apt/sources.list
    echo "deb http://httpredir.debian.org/debian jessie main" >> /etc/apt/sources.list
    apt-get update

	
**2. Récupérez la dernière version (X.Y.Z à remplacer par le numéro de version) de GeoNature-atlas sur le dépot (https://github.com/PnEcrins/GeoNature-atlas/releases)**
	
Ces opérations doivent être faite avec l'utilisateur courant (autre que ``root``), ``monuser`` dans l'exemple :

::

    su monuser
    cd /home/monuser
    wget https://github.com/PnEcrins/GeoNature-atlas/archive/X.Y.Z.zip
    
:notes:

    Si la commande ``wget`` renvoie une erreur liée au certificat, installez le paquet ``ca-certificates`` (``sudo apt-get install ca-certificates``) puis relancer la commande ``wget`` ci-dessus.

Dézippez l'archive :
	
::

    unzip X.Y.Z.zip
	
Vous pouvez renommer le dossier qui contient l'application (dans un dossier ``/home/monuser/atlas/`` par exemple) :
	
::

    mv GeoNature-atlas-X.Y.Z atlas

**3. Placez-vous dans le dossier qui contient l'application et lancez l'installation automatique de l'environnement :**
	
::

    cd atlas/
    ./install_env.sh


Configuration d'Apache
======================

Créez un virtualhost pour l'atlas :
	
::

    sudo nano /etc/apache2/sites-available/atlas.conf

Copier/collez-y ces lignes en renseignant votre nom d'utilisateur à la place de MONUSER (deux premières lignes) : 

::

    WSGIScriptAlias / /home/MONUSER/atlas/atlas.wsgi
     <Directory "/home/MONUSER/atlas">
       WSGIApplicationGroup %{GLOBAL}
       WSGIScriptReloading On
       Require all granted
     </Directory>

:notes:

    Ici l'application sera consultable à la racine de l'URL du serveur. Si vous souhaitez qu'elle soit accessible dans un sous répertoire (http://monURL/atlas par exemple), modifier la premiere ligne en ``WSGIScriptAlias /atlas /home/MONUSER/atlas/atlas.wsgi``
	
	
Si l'atlas est associé à un domaine, ajoutez ces 2 premières lignes au début du fichier :
	 
::

    ServerName mondomaine.fr
    DocumentRoot /home/MONUSER/atlas/
 

Activez le virtualhost puis redémarrez Apache :

::

    sudo a2ensite atlas
    sudo apachectl restart

   
Configuration de PostgreSQL
===========================

Par défaut un serveur PostgreSQL n'écoute et n'autorise des connexions que du serveur lui-même (localhost). 

Si vous souhaitez vous y connecter depuis un autre serveur ou PC, connectez-vous en SSH sur le serveur de la BDD de l'atlas, puis éditez les fichiers de configuration de PostgreSQL.

Pour écoutez toutes les IP, éditez le fichier ``postgresql.conf`` :

::

    sudo nano /etc/postgresql/9.4/main/postgresql.conf

Remplacez ``listen_adress = 'localhost'`` par  ``listen_adress = '*'``. Ne pas oublier de décommenter la ligne (enlever le ``#``).

Pour définir les IP qui peuvent se connecter au serveur PostgreSQL, éditez le fichier ``pg_hba.conf``

::

    sudo nano /etc/postgresql/9.4/main/pg_hba.conf

Si vous souhaitez définir des IP qui peuvent se connecter à la BDD, sous la ligne ``# IPv4 local connections:``, rajouter : 

::

    host    all     all     MON_IP_A_REMPLACER/0        md5  #Pour donner accès depuis n'importe quelle IP
    
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


Installation de la base de données
==================================

Modifiez le fichier de configuration de la BDD et de son installation automatique ``main/configuration/settings.ini``. 

Attention à ne pas mettre de 'quote' dans les variables, même pour les chaines de caractères.

L'atlas n'est pas livré avec la couche SHP de l'emprise du territoire. 

Uploadez votre fichier .shp de l'emprise de votre territoire dans le dossier ``data/ref`` sous le nom ``emprise_territoire.shp``. Attention à bien mettre les fichiers .shp, .dbf, .shx et prj.

Comme indiqué dans le fichier ``settings.ini``, vous pouvez faire de même pour importer un SHP des communes de votre territoire.

L'application se base entièrement sur des vues matérialisées. Par défaut, celles-ci sont proposées pour requêter les données dans une BDD GeoNature. Mais cela, laisse la possibilité de la connecter à une autre BDD.

.. image :: images/geonature-atlas-schema-02.jpg

Ainsi si vous n'utiliser pas GeoNature comme données sources, commencez par éditer la vue ``atlas.vm_observations`` dans ``data/atlas.sql`` en respectant impérativement les noms de champs.

.. image :: images/geonature-atlas-schema-01.jpg

Plus de détails sur les différentes vues matérialisées dans le fichier ``data/vues_materialisees_maj.rst`` qui indique aussi comment automatiser leur mise à jour.

>> Fournir exemple atlas.vm_observations basé sur une BDD SICEN

Par ailleurs, si vous n'utilisez pas GeoNature, il vous faut installer TaxHub (https://github.com/PnX-SI/TaxHub/) ou au moins sa BDD (https://github.com/PnX-SI/TaxHub/blob/master/data/taxhubdb.sql), pour gérer les attributs (description, commentaire, milieu et chorologie) ainsi que les médias rattachés à chaque espèce (photos, videos, audios et articles)

Si vous souhaitez uniquement installer le schéma ``taxonomie`` de TAXHUB dans la BDD de l'atlas, il vous faut éxécuter ces quelques lignes : https://github.com/PnX-SI/TaxHub/blob/master/install_db.sh#L47-L64

>> A préciser et automatiser. PB à solutionner, pour cela il faudrait commencer par créér la BDD, y intégrer le schéma taxonomie de TaxHub puis lancer le script l'installation automatique de la BDD de GeoNature-atlas. Hors son script ne fonctionne pas si la BDD existe déjà... Ajouter paramètre pour gérer cela. En attendant, si on veut faire cela, il faut éxécuter ce qu'il y a dans ``install_db.sh`` bout par bout à la main, sans le lancer globalement...

Ca donnerait un truc de ce genre à intégrer dans ``install_db.sh`` et à n'éxécuter que si un paramètre ``INSTALL_TAXHUB_DB`` est à True...

::

    cd data
    wget https://raw.githubusercontent.com/PnX-SI/TaxHub/master/data/taxhubdb.sql
    export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f taxhubdb.sql  &>> logs/install_db.log
    wget https://github.com/PnX-SI/TaxHub/raw/master/data/inpn/TAXREF_INPN_v9.0.zip
    unzip TAXREF_INPN_v9.0.zip -d /tmp
    wget https://raw.githubusercontent.com/PnX-SI/TaxHub/master/data/inpn/data_inpn_v9_taxhub.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name  -f data/inpn/data_inpn_v9_taxhub.sql &>> logs/install_db.log
    # data/vm_hierarchie_taxo.sql est encore utilisé ?
    wget https://raw.githubusercontent.com/PnX-SI/TaxHub/master/data/inpn/taxhubdata.sql
    export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f data/taxhubdata.sql  &>> logs/install_db.log
    rm /tmp/*.txt
    rm /tmp/*.csv
    cd ..

Lancez le fichier fichier d'installation de la base de données en sudo :

::

    sudo ./install_db.sh
    
:notes:

    Vous pouvez consulter le log de cette installation de la base dans ``log/install_db.log`` et vérifier qu'aucune erreur n'est intervenue. 

Configuration de l'application
==============================   

Ouvrir le fichier de configuration ``main/configuration/config.py``.

- renseigner la variable 'database_connection'
- renseigner l'url de l'application '/atlas' ou '' si il n'y a pas de 'sous-domaine' dans la conf apache
- customiser l'application...

Customisation de l'application
==============================   
	
En plus de la configuration, vous pouvez customisez l'application en modifiant et ajoutant des fichiers présents dans le répertoire ``static/custom/`` (css, templates, images
	
Mise à jour de l'application
============================

- Télécharger puis dézipper la nouvelle version de l'atlas à installer dans ``/home/monuser``.
- Renommer l'ancienne version de l'atlas puis la nouvelle version, en lui donnant le nom du répertoire précédemment utilisé si vous voulez éviter de devoir modifier votre configuration Apache.
- Ou y créer un nouveau répertoire pour l'application et ``git clone`` de la version souhaitée depuis le dépot Github.

:notes:

    A la racine de l'application, un fichier ``VERSION`` permet de savoir quelle version est installée. 

- Copier ``main/configuration/settings.ini`` et ``main/configuration/config.py`` depuis l'ancienne version vers la nouvelle pour récupérer vos paramètres de configuration
- Copier ``static/custom/`` depuis l'ancienne version vers la nouvelle pour récupérer toute votre customisation (CSS, templates, images...)
- Redémarrez Apache

Attention à bien lire les notes de chaque version, qui peuvent indiquer des opérations spécifiques à faire, notamment des nouveaux paramètres à ajouter dans votre configuration et/ou des modifications à appliquer dans la BDD


Mise à jour des couches de référence
====================================

Limite du territoire ou communes.
	
Voir les parties concernées dans ``install_db.sh``.
	
	