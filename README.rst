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

Documentation
-------------

* `Installation <docs/installation.rst>`_
* `Présentation des vues materialisées et installation dans un contexte sans GeoNature <docs/vues_materialisees_maj.rst>`_
* `Configuration et customisation de l'application <docs/configuration.rst>`_
* `Multilingue <docs/multilingual.rst>`_
* `Gestion et affichage des données sensibles <docs/sensibilite_donnees.md>`_
* `Cookies et RGPD <docs/cookies_rgpd.rst>`_
* `Contribution <docs/CONTRIBUTING.md>`_
* `Changelog <docs/changelog.rst>`_

Rapports et présentations
--------------------------

* `Rapport de stage - Théo Lechemia (2016) <docs/2016-09-30-rapport_stage_Theo-Lechemia.pdf>`_
* `Soutenance - Théo Lechemia (2016) <docs/2016-09-soutenance-Theo-Lechemia.pdf>`_
* `Présentation GeoNature Atlas (2016) <docs/2016-09-GeoNature-atlas-PRESENTATION.pdf>`_


Technologies
------------

- Langages : Python, HTML, JS, CSS
- BDD : PostgreSQL, PostGIS
- Serveur : Debian
- Framework Python : Flask
- Framework JS : jQuery
- Framework carto : Leaflet
- Serveur carto : Aucun
- Fonds rasters : Geoportail, OpenStreetMap, Google Maps, WMS...

Exemples d'atlas en ligne utilisant GeoNature-atlas :
-----------------------------------------------------

- `PN du Mercantour <http://biodiversite.mercantour-parcnational.fr>`_
- `PN de la Vanoise <http://biodiversite.vanoise-parcnational.fr>`_
- `PN des Ecrins <http://biodiversite.ecrins-parcnational.fr>`_ 
- `PNR Normandie Maine <https://biodiversite.parc-naturel-normandie-maine.fr>`_
- `CEN des Pays de la Loire <http://www.biodiv-paysdelaloire.fr>`_
- `Atlas du Languedoc-Roussillon <https://atlas.libellules-et-papillons-lr.org>`_
- `LPO Auvergne-Rhône-Alpes <https://carto.fauneauvergnerhonealpes.org>`_
- `OcNat <https://biodiv-occitanie.fr>`_
- `Société Herpétologique de France <https://atlas.lashf.org>`_
- `Picardie Nature <https://clicnat.fr>`_
- `Métropole clermontoise <https://atlas.cbiodiv.org>`_
- `PNR Forêt d'Orient <https://biodiversite.pnr-foret-orient.fr>`_
- `Archipel des Mascareignes <https://obs.maeoproject.org>`_
- `Biodiv13 <https://hop-levivant.fr>`_
- `Biodiv06 <https://www.biodiv06-lpo.org>`_
- `Biodiv'PACA <https://www.biodivpaca-lpo.org>`_
- `Atlas de la faune et de la flore de La Réunion <http://atlas.borbonica.re>`_
- `Silene Nature <https://nature.silene.eu>`_
- `Biodiv'Rennes <https://abc-biodivrennes.fr/atlas>`_


Auteurs
-------

- Théo Lechemia
- Gil Deluermoz
- Camille Monchicourt
- Amandine Sahl

Licence
-------

* OpenSource - GPL V3
* Copyright (c) 2016-2022 - Parc National des Écrins

.. image:: http://geonature.fr/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr
