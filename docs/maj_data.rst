======================
MISE A JOUR DU CONTENU
======================
.. image:: http://geotrek.fr/images/logo-pne.png
    :target: http://www.ecrins-parcnational.fr

-----


Les données contenues dans les vues matérialisées n'intègrent pas en temps réel les mises à jours faites dans GeoNature; Pour cela ces vues doivent être actualisées grace à une commande ``refresh``.
Une fonction, générée lors de la création de la base de l'atlas permet de mettre à jour toutes les vues matérialisées du schéma atlas.

* Pour lancer manuellement cette fonction, ouvrez une console SQL et exécuté la commande suivante :

    ::
        
        SELECT RefreshAllMaterializedViews('atlas');

* Pour automatiser la commande, ajouter la dans le crontab de l'utilisateur root : 

    ::
        sudo crontab -e

    ajouter la ligne suivante en prenant soin de mettre à jour les paramètres de connexion à la base de l'atlas :

    ::
        
        0 4 * * * export PGPASSWORD='monpassachanger';psql -h localhost -U geonatatlas -d geonatureatlas -c "SELECT RefreshAllMateriali$

    Pour enregistrer et sortir : ``ctrl + o`` puis ``ctrl + x``