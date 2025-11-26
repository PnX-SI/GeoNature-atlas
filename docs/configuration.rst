Configuration
=============


Le fichier `atlas/configuration/config.py` contient l'ensemble des variables de configuration de l'atlas.

Ajout de fiche "zonage"
-----------------------

Par défaut l'atlas est configuré avec des fiches "commune". Il est possible d'ajouter d'autres types de zonage présent dans la table `ref_geo.bib_areas_type` de GeoNature.
Remplissez le paramètre `TYPE_TERRITOIRE_SHEET` avec le champs `type_code` de `ref_geo.bib_areas_type`
L'ajout de nouveaux type de zonage necessite de prendre en compte la question du floutage des données sensible : voir le `document  <degradation_donnees.rst>`_