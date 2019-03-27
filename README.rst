GeoNature-atlas
===============

.. image :: docs/images/geonature-atlas-screenshot.jpg

Atlas WEB dynamique Faune-Flore basé sur les données présentes dans la synthèse de `GeoNature <http://geonature.fr>`_.

Utilisé pour Biodiv'Ecrins, l'atlas de faune et de la flore du Parc national des Ecrins (http://biodiversite.ecrins-parcnational.fr).

Il permet de générer dynamiquement des fiches espèces avec des données calculées automatiquement (cartes de répartition, répartition altitudinale et phénologique, communes, secteurs, observateurs...) ainsi que des données saisies pour chaque espèce (photos, description...). 

L'outil a été développé de manière générique pour pouvoir être déployé sur d'autres BDD que GeoNature (SERENA, SICEN, INPN, fichier CSV, etc).

**Interrogez vos observations naturalistes, croisez-les avec TAXREF, publiez votre atlas en ligne dynamique**

.. image :: docs/images/geonature-atlas-schema-01.jpg

**Ou déployez l'ensemble complet d'applications de gestion de données naturalistes** (`UsersHub <https://github.com/PnX-SI/UsersHub>`_, `TaxHub <https://github.com/PnX-SI/TaxHub>`_, `GeoNature <https://github.com/PnX-SI/GeoNature>`_)

.. image :: docs/images/geonature-atlas-schema-02.jpg

Documentation d'installation : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/installation.rst

Présentation générale : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/2016-09-GeoNature-atlas-PRESENTATION.pdf

Rapport de stage (Théo Lechemia) : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/2016-09-30-rapport_stage_Theo-Lechemia.pdf

Soutenance de stage (Théo Lechemia) : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/2016-09-soutenance-Theo-Lechemia.pdf

Technologies
------------

- Langages : Python, HTML, JS, CSS
- BDD : PostgreSQL, PostGIS
- Serveur : Debian ou Ubuntu
- Framework Python : Flask
- Framework JS : jQuery
- Framework carto : Leaflet
- Serveur carto : Aucun
- Fonds rasters : Geoportail, OpenStreetMap, Google Maps, WMS...

Généricité
----------

L'API de GeoNature-atlas se sert directement dans des vues. Ainsi chacun peut personnaliser ses vues en fonction des besoins et des différences dans les tables. 

L'ensemble des vues sont regroupées dans un schéma spécifique « atlas », ce qui laisse la possibilité de les remplir avec autre chose que GeoNature.

Auteurs
-------

- Théo Lechemia
- Gil Deluermoz
- Camille Monchicourt
- Amandine Sahl

Licence
-------

* OpenSource - GPL V3
* Copyright (c) 2016-2019 - Parc National des Écrins


.. image:: http://geonature.fr/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr

