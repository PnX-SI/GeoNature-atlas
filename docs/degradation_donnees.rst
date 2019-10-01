Dégradation des données
=======================

GeoNature-atlas fournit un mécanisme de dégration des données basé sur les standards du SINP. Connecté à GeoNature version 2, l'atlas utilise le champs ``id_nomenclature_diffusion_level`` de la table ``gn_synthese.synthese`` pour construire la vue ``atlas.vm_observations`` et remplir la géometrie adaptée en se basant sur référentiel géographique de GeoNature. Pour des raisons de performance et de lisibilité, GeoNature-atlas affiche le centroïde de la géometrie à laquelle l'observation est dégradée (le centroïde de communes si le niveau de diffusion est = 1 par exemple). Les données dont le niveau de diffusion est égal à 4 (aucune diffusion) ne sont pas affichées dans GeoNature-atlas. Non connecté à GeoNature2, la charge de la dégradation géographique est à la charge de l'administrateur des données.

Voir la nomenclature du "Niveaux de précision de diffusion souhaités" du SINP http://standards-sinp.mnhn.fr/nomenclature/5-niveaux-de-precision-de-diffusion-souhaites-niveauprecision-23-06-2016/.

A partir des données bruts présentes dans GeoNature, l'atlas applique le floutage suivant :

* 0 -	Diffusion standard : à la maille, à la ZNIEFF, à la commune, à l’espace protégé (statut par défaut).
* 1	- Diffusion floutée de la DEE par rattachement à la commune.
* 2	- Diffusion floutée par rattachement à la maille 10 x 10 km
* 3	- Diffusion floutée par rattachement au département.
* 4	- Aucune diffusion (cas exceptionnel), correspond à une donnée de sensibilité 4.
* 5	- Diffusion telle quelle : si une donnée précise existe, elle doit être diffusée telle quelle.

Une symbologie adaptée est fournie par défaut dans GeoNature-atlas (en vert les données dégradées, en bleu les données précises). Cette symbologie est customisable dans le fichier ``static/custom/maps-custom.js`` et permet plus largement de personnaliser l'affichage en fonction des informations renvoyées par la vue ``atlas.vm_observations`` (voir `<installation.rst#customisation-de-lapplication>`_).
