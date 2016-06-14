============
INSTALLATION
============
.. image:: http://geotrek.fr/images/logo-pne.png
    :target: http://www.ecrins-parcnational.fr

-----

Prérequis
=========

Application développée et installée sur un serveur contenant :

- Ubuntu 14.04
- PostgreSQL 9.1
- PostGIS 1.5
- Apache

Installation de PostgreSQL
==============================

Voir commandes GeoNature, dbhost ?, utilisateur geonatatlas obligatoire ???

Installation de l'application
=============================

* Récupérer le zip de l’application sur le Github du projet (`X.Y.Z à remplacer par le numéro de version souhaitée <https://github.com/PnEcrins/GeoNature-atlas/releases>`_), dézippez le dans le répertoire de l'utilisateur linux du serveur puis copiez le dans le répertoire de l’utilisateur linux :
 
  ::  
  
        cd /home/synthese
        wget https://github.com/PnEcrins/GeoNature-atlas/archive/vX.Y.Z.zip
        unzip vX.Y.Z.zip
        mv GeoNature-X.Y.Z/ geonature/

        
Configuration de la base de données PostgreSQL
==============================================

* Se positionner dans le répertoire de l'application ; par exemple ``geonatureatlas`` :
 
  ::  
  
	cd geonatureatlas
        
* Copier et renommer le fichier ``config/settings.ini.sample`` en ``config/settings.ini`` :
 
  ::  
  
        cp config/settings.ini.sample config/settings.ini

* Mettre à jour le fichier ``config/settings.ini`` avec vos paramètres de connexion à la BDD :
 
  ::  
  
	nano config/settings.ini

Renseigner le nom de la base de données, les utilisateurs PostgreSQL et les mots de passe. Il est possible mais non conseillé de laisser les valeurs proposées par défaut. 

???? ATTENTION : Les valeurs renseignées dans ce fichier sont utilisées par le script d'installation de la base de données ``install_db.sh``. Les utilisateurs PostgreSQL doivent être en concordance avec ceux créés lors de la dernière étape de l'installation du serveur 

???? Paramétrer si on veut créer la BDD fille basée sur GeoNature ou si on veut juste le schéma atlas dont on adaptera les vues à son contexte.

???? Je capte pas bien le fichier settings.ini. Et si une structure n'utilise par GeoNature que faire des hosts de la BDD mère ???

Création de la base de données
==============================

Par défaut, la BDD a été conçue pour s'appuyer sur les données présentes dans GeoNature (https://github.com/PnEcrins/GeoNature). 

Pour cela une BDD fille de GeoNature est créée dans GeoNature-atlas avec les schémas utiles à l'atlas (``synthese``, ``taxonomie``, ``layers``, ``utilisateurs``), alimentée grace à un Foreign Data Wrapper (http://docs.postgresqlfr.org/9.2/sql-createforeigndatawrapper.html).

Cela permet de créer un lien dynamique entre les 2 bases de données. A chaque fois qu'une requête est éxecutée dans une table de l'atlas (BDD fille), le FWD permet d'interroger directement dans le BDD mère (celle de GeoNature) et ainsi d'avoir les données à jour en temps réel. 

Néanmoins pour plus de généricité et permettre à une structure d'utiliser GeoNature-atls sans disposer de GeoNature, l'application ne requête jamais directement dans ces schémas liés à GeoNature. 

En effet elle requête uniquement sur des vues créées dans le schéma spécifique ``atlas``.

Ainsi ces vues peuvent être adaptées à volonté pour interroger d'autre sources de données que GeoNature, à partir du moment où elles retournent les mêmes champs. 

Dans un soucis de performance et pour ne pas requêter en permanence sur le base mère GeoNature, nous avons mis en place des vues matérialisées (http://docs.postgresqlfr.org/9.3/rules-materializedviews.html) pour que les données soient précalculées, indéxées et présentes directement dans le schéma ``atlas``. 

**Liste des vues** :

- atlas.vm_taxref qui renvoie toutes les données de taxonomie.vm_taxref.
    Champs à préciser pour ceux qui n'ont pas taxonomie.vm_taxref

- atlas.vm_observations qui renvoie la liste de toutes les observations.
    Champs à renommer et supprimer dans la vue par défaut. 
    
- atlas.vm_taxons qui renvoie la liste des taxons observés au moins une fois sur le territoire.

- atlas.vm_altitudes qui renvoie le nombre d'observations pour chaque classe d'altitude et chaque taxon.

- atlas.vm_phenologies qui renvoie le nombre d'observations pour chaque mois et chaque taxon.

Insérer un schema des BDD.

* Lancer le script automatique de création de la BDD
 
  ::  
  
        sudo ./install_db.sh
        
* Vous pouvez consulter le log de cette installation de la base dans ``log/install_db.log`` et vérifier qu'aucune erreur n'est intervenue. **Attention, ce fichier sera supprimé** lors de l'exécution de ``install_app.sh``

#################################
        
**Connexion à la base de données** 

Créez un fichier de configuration à partir du fichier d'exemple :
::
        cp config/config.py.sample config/config.py

Renseignez vos informations de connexion dans le fichier ``config/config.py``.


**Configuration Apache** 

???? Partir de doc GeoSites ou doc GeoNature pour Apache ???

Créez un fichier de configuration apache ``.htaccess`` à partir du fichier d'exemple :
::
        cp .htaccess.sample .htaccess

Si l'url de votre application n'est pas celle de votre domaine (ou sous domaine), modifiez la partie 
::
        RewriteBase / 

Et indiquez le chemin après le ``/``. Par exemple si votre application se trouve à cette url ``http://mondomaine/atlas``, modifiez la variable ``RewriteBase`` ainsi
::
       RewriteBase /atlas/ 
       

Personnalisation de l'application
=================================

* Créez un fichier de configuration de l'application à partir du fichier d'exemple :

::
        cp static/conf/custom.sample.js static/conf/custom.js

* Adapter le contenu du fichier ``static/conf/custom.js``
        
* Modifier éventuellement les vues dans le schéma ``atlas``

Vous pouvez alimenter l'atlas avec une autre source de données que GeoNature à condition de respecter le nom des champs retournés par la vue.

Ou vous simplement décider de l'adapter à votre GeoNature par exemple en changeant l'``id_organisme`` dont vous souhaitez afficher les données dans la condition WHERE de ``atlas.vm_observations``.

Modifiez les images dans le répertoire ``/static/images/``.

!!!! Dissocier les images de l'atlas (pictos, boutons...), les images liées à la custo (à mettre dans un dossier à part comme /medias/, voir Geotrek et les images liées au contenu)

Vous pouvez modifier les pages d'information en éditant les fichiers HTML dans le répertoire ``/templates/`` et notamment, adaptez le contenu des fichiers :

!!!!! Modifier le texte de présentation générale, quelques labels dans une surcouche ???

!!!!! Pensez à la procédure de mise à jour de l'appli et regrouper le plus possibl les fichiers de customisation et de surcouche pour les rapatrier facilement au moment d'une mise à jour. 
    

Développement
=============

Généricité à compléter...