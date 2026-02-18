============================================
Vues materialisees et mise a jour du contenu
============================================


Introduction
============

Par défaut, la BDD a été conçue pour s'appuyer sur les données présentes dans GeoNature (https://github.com/PnEcrins/GeoNature).

Pour cela une BDD fille de GeoNature est créée avec les schémas utiles à l'atlas (``atlas``, ``gn_meta``, ``gn_sensitivity`` ``gn_synthese``, ``taxonomie``, ``ref_geo``, ``ref_nomenclatures``, ``utilisateurs`` ), alimentée grace à un Foreign Data Wrapper (http://docs.postgresqlfr.org/9.2/sql-createforeigndatawrapper.html).

Cela permet de créer un lien dynamique entre les 2 bases de données. A chaque fois qu'une requête est éxecutée dans une table de l'atlas (BDD fille), le FDW permet d'interroger directement dans le BDD mère (celle de GeoNature) et ainsi d'avoir les données à jour en temps réel.

.. image :: images/bdd-fdw-vm.png

Néanmoins pour plus de généricité et permettre à une structure d'utiliser GeoNature-atlas sans disposer de GeoNature, l'application ne requête jamais directement dans ces schémas liés à GeoNature.

Dans un soucis de performance et pour ne pas requêter en permanence sur la base mère GeoNature, nous avons mis en place des vues matérialisées (http://docs.postgresqlfr.org/9.3/rules-materializedviews.html) pour que les données soient précalculées, indéxées et présentes directement dans le schéma ``atlas``.

Vous pouvez alimenter l'atlas avec une autre source de données que GeoNature (voir section 3.1 de la documentation d'installation).

Liste des vues matérialisées principales
=========================================

Voir les fichiers dans le répertoire ``data`` pour plus de précisions.

- ``atlas.vm_taxref`` qui renvoie toutes les données de ``taxonomie.taxref``
- ``atlas.vm_observations`` qui renvoie toutes les observations.
- ``atlas.vm_cor_area_synthese`` : VM de correspondance (N-N) entre une observation et un zonage (``atlas.vm_l_areas``)
- ``atlas.vm_cor_maille_observation``: renvoie pour chaque observation quelle est la géométrie de flouage (calculé à partir de ``atlas.vm_cor_maille_observation`` et ``atlas.vm_cor_sensitivity_area_type``)
- ``atlas.vm_cor_sensitivity_area_type`` : table de relation entre un niveau de sensibilité et un type de zonage
- ``atlas.vm_taxons`` qui renvoie la liste des taxons observés au moins une fois sur le territoire (présents dans vm_observations).
- ``atlas.vm_search_taxon`` qui renvoie l'ensemble de tous les taxons + tous leurs synonymes pour le module de recherche d'une espèce.
- ``atlas.vm_altitudes`` qui renvoie le nombre d'observations pour chaque classe d'altitude et chaque taxon. Cette vue peut être personnalisée pour adapter les classes d'altitude (Voir ci-dessous : "Personnalisation de l'application").
- ``atlas.vm_mois`` qui renvoie le nombre d'observations pour chaque mois et chaque taxon.
- ``atlas.vm_l_areas`` est une copie de la table ``ref_geo.l_areas`` de GeoNature, elle contient tous les zonages necessaire à l'atlas (fiche territoire + zonages lié à la sensibilité)
- ``atlas.vm_medias`` qui renvoie tous les médias des taxons, sur la base du schéma ``taxonomie`` de TaxHub
- ``atlas.vm_cor_taxon_attribut`` qui renvoie les attributs TaxHub des taxons. Par défaut : description, commentaire, milieux, chorologie, sur la base du schéma ``taxonomie`` de TaxHub.



**Modèle conceptuel du schéma `atlas`**

.. image :: images/mcd-atlas.png

**A partir de TAXREF et des observations, on génère la vue des taxons et on calcule des informations sur chaque taxon (carte des observations, graphiques, taxonomie...)**

.. image :: images/mcd-vm.png

**On peut aussi décrire chaque taxon (attributs) et y associer des médias (photos, audios, vidéos, articles...)**

.. image :: images/mcd-attributs-medias.png


Personnaliser les classes d'altitude
====================================

Pour modifier la vue ``vm_altitudes``, modifiez le paramètre `altitudes` du fichier `settings.ini` puis relancer l'instalation de la base de données.


Mise à jour des vues matérialisées
==================================

Dans un soucis de performance, les données contenues dans les vues matérialisées n'intègrent pas en temps réel les mises à jour faites dans GeoNature. Pour cela ces vues doivent être actualisées grace à la fonction ``REFRESH MATERIALIZED VIEW`` ajouté dans le schéma ``public`` de PostgreSQL.

Une fonction, générée lors de la création de la BDD de GeoNature-atlas permet de mettre à jour toutes les vues matérialisées du schéma ``atlas``.

* Pour lancer manuellement cette fonction, ouvrez une console SQL et exécutez la requête suivante :

  ::

        SELECT RefreshAllMaterializedViews('atlas');

* Si vous utilisez une version de PostgreSQL inférieure à 9.4, le rafraichissement concurrent des vues matérialisées (https://www.postgresql.org/docs/9.4/static/sql-refreshmaterializedview.html) n'est pas possible. Dans ce cas, modifiez la fonction comme indiqué dans ses commentaires (https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/atlas.sql#L424).

* Pour automatiser l'éxecution de cette fonction (toutes les heures dans cet exemple), ajoutez la dans le crontab de l'utilisateur ``postgres`` :

  ::

        sudo su postgres
        crontab -e

Ajouter la ligne suivante en prenant soin de mettre à jour les paramètres de connexion à la base de GeoNature-atlas :

::

    0 * * * * psql -d geonatureatlas -c "SELECT RefreshAllMaterializedViews('atlas');"


Cette fonction rafraichit toutes les vues materialisées présentes dans le schéma ``atlas`` et ne tient pas compte de l'ordre du rafraichissement. Cette opération peut-être assez longue dans le cas où le réferentiel géographique est volumineux alors que celui-ci est relativement stable (peu de MAJ des communes ou du territoire).

Dans ce cas, préferez un rafraichisement automatique uniquement des données : fonction ``atlas.refresh_materialized_view_data()``. Pour rafraichir les données géographiques, lancer ponctuellement la fonction ``atlas.refresh_materialized_view_ref_geo()``.
