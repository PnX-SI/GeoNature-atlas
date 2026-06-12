===================
Installation Docker
===================

L'installation Docker permet d'installer GeoNature-atlas dans un environnement complétement isolé et dans un autre OS que ceux supportés dans l'installation classique. Il permet également d'installer plusieurs GeoNature-atlas sur le même serveur.

Comme pour l'installation standard, téléchargez le code source et assurez vous d'avoir Docker installé sur la machine.

Désampler le fichier ``atlas/configuration/setting.ini.sample`` et remplissez le.

Le fichier ``docker-compose.yml`` fournit une installation complète par défaut qui créé un container Docker PostgreSQL pour la base de données de GeoNature-atlas (le paramètre ``db_host`` de ``settings.ini`` doit être ``postgres``).
Le container Docker de la base de données peut lire en FDW des bases de données situées sur le même host, dans un autre container Docker ou même sur un autre serveur (selon ce qui est indiqué dans le paramètre ``db_source_host`` du fichier ``settings.ini``).

Lancer l'installation de la BDD : 

::

    ./docker-compose.sh run --rm atlas-app install/install_db.sh --docker

Lancer l'application : 

::

    ./docker-compose.sh up -d

Par défaut le container ``atlas-app`` expose le port 8080 sur lequel tourne l'application.
Il faudra ensuite mettre le proxy que vous souhaitez sur l'hôte : Apache, NGINX. Une configuration Apache d'exemple est fournie dans la rubrique "Configuration d’Apache" de la documentation.

.. note::

    Le Docker Compose et le script ``install_db.sh`` fournis ne permettent pas d'installer la base de données de GeoNature-atlas dans la même BDD que celle de GeoNature. Nous recommandons d'installer GeoNature-atlas dans une base de données séparée.

Images Docker
-------------

3 images Docker sont fournies, une pour la production, une pour la pré-production et une pour le développement.

Si vous souhaitez regénérer ces images : 

::
    
    # image de production
    docker build -t atlas:prod --target prod .
    # image de préproduction
    docker build -t atlas:preprod --target preprod .
    # image de dev 
    docker build -t atlas:dev --target dev .
