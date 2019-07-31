Cet exemple est basé sur une Debian 9. A adapter selon votre OS.


On ajoute un fichier ``sources.list`` pour permettre d'installer la version de postgresql sans être dépendant de celle liée au ``sources.list`` de sa version d'OS :

::

    sudo touch /etc/apt/sources.list.d/pgdg.list
    sudo echo "#Ajout des sources pour les differentes versions de PostGreSQL" | sudo tee -a /etc/apt/sources.list.d/pgdg.list
    sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list


On ajoute les signatures du dépôt puis on remet à jour la liste des paquets :

::

    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
        sudo apt-key add -
    sudo apt-get update
