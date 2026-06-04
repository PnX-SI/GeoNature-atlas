==============================================
Installation de GeoNature-atlas sans GeoNature
==============================================

Si vous n'utilisez pas GeoNature, suivez la documentation standard, puis au moment d'installer la base de données, réferrez vous à cette documentation.
Il faudra au préalable installer TaxHub (https://github.com/PnX-SI/TaxHub/) pour gérer les attributs (description, commentaire, milieu et chorologie) ainsi que les médias rattachés à chaque espèce (photos, videos, audios et articles). TaxHub est également fourni avec un réferentiel géographique (schema `ref_geo``) qui est nécessaire au bon fonctionnement de GeoNature-atlas.

⚠️ L'atlas devra alors impérativement être installé dans la même BDD que TaxHub.

Une fois TaxHub installé, il est nécessaire d'ajouter des migrations alembic pour ajouter les mailles nécessaires à GeoNature-atlas.

::

    # se mettre dans le venv de TaxHub

    # mettre à jour le schéma ref_geo
    flask db upgrade ref_geo@head
    source <chemin_vers_repertoire_taxhub>/venv/bin/activate
    # ajout des mailles 1
    flask db upgrade ref_geo_inpn_grids_1@head
    # ajout des mailles 5
    flask db upgrade ref_geo_inpn_grids_5@head
    # ajout des mailles 10
    flask db upgrade ref_geo_inpn_grids_10@head
    # ajout des communes
    flask db upgrade ref_geo_fr_municipalities@head
    # ajout des départements
    flask db upgrade ref_geo_fr_departments@head


A noter aussi que si vous ne connectez pas GeoNature-atlas à une BDD GeoNature (``geonature_source=false``), série de tables et des données d'exemples sont créées (voir script ``without_geonature.sql`` pour simuler la structure d'un base GeoNature. A vous d'alimenter ces tables après l'installation ou les remplacer par des vues pour les connecter à votre source de données.
