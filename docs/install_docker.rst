===================
Installation Docker
===================


L'installation Docker permet d'installer GeoNatureatlas dans un environnement complétement isolé et dans un autre OS que ceux supportés dans l'installation classique. Il permet également d'installer plusieurs GeoNatrue-atlas sur le même serveur.
Comme pour l'installation standard, téléchargez le code source et assurez vous d'avoir Docker installé sur la machine.

Désampler le fichier ``atlas/configuration/setting.ini.sample`` et remplissez le.
Le fichier ``docker-compose.yml`` fourni une installation qui crée un container docker PostgreSQL pour la base de données (le paramètre ``db_host`` doit valoir ``postgres``).
Le container docker de la base de données peut lire en FDW des bases de données situées sur le même host, dans un autre container docker ou même sur un autre serveur.

Lancer l'installation de la BDD : 

::

    ./docker-compose.sh run --rm atlas-app install/install_db.sh --docker

Lancer l'application : 

::

    ./docker-compose.sh up

Par défaut le container ``atlas-app`` expose le port 8080 sur laquelle tourne l'application.
Il faudra ensuite mettre le proxy que vous souhaitez sur l'hôte : Apache, NGINX. Une configuration Apache est fournie dans la rubrique "Configuration d’Apache"


.. note::

    Le docker compose et le script ``install_db.sh`` fourni ne permettent pas d'installer la base de données de GeoNature-atlas dans la même BDD que celle de GeoNature. Nous recommandons d'installer GeoNature-atlas dans une base de données séparée.

Images docker
-------------

3 images docker sont fournies, un pour la production, une pour la pré-production et une pour le développement.
Si vous souhaitez regénérer ces images : 

::
    
    # image de production
    docker build -t atlas:prod --target prod .
    # image de préproduction
    docker build -t atlas:preprod --target preprod .
    # image de dev 
    docker build -t atlas:dev --target dev .
