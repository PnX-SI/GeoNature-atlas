======================
MISE A JOUR DU CONTENU
======================
.. image:: http://pnecrins.github.io/GeoNature/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr

-----

Dans un soucis de performance, les données contenues dans les vues matérialisées n'intègrent pas en temps réel les mises à jour faites dans GeoNature. Pour cela ces vues doivent être actualisées grace à la fonction ``REFRESH MATERIALIZED VIEW`` de PostgreSQL.
Une fonction, générée lors de la création de la BDD de GeoNature-atlas permet de mettre à jour toutes les vues matérialisées du schéma ``atlas``.

* Pour lancer manuellement cette fonction, ouvrez une console SQL et exécutez la requête suivante :
    
  ::  
  
        SELECT RefreshAllMaterializedViews('atlas');

* Pour automatiser l'éxecution de cette fonction (chaque nuit à 4 heures dans cet exemple), ajoutez la dans le crontab de l'utilisateur ``root`` :
    
  ::  
  
        sudo crontab -e


Ajouter la ligne suivante en prenant soin de mettre à jour les paramètres de connexion à la base de GeoNature-atlas :
    
::

    0 4 * * * export PGPASSWORD='monpassachanger';psql -h localhost -U geonatatlas -d geonatureatlas -c "SELECT RefreshAllMaterializedViews('atlas');"

Pour enregistrer et sortir : ``Ctrl + O`` puis ``Ctrl + X``
