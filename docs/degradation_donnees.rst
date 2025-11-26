Dégradation des données
=======================

GeoNature-atlas fournit un mécanisme de dégration des données basé sur les standards du SINP. Connecté à GeoNature version 2, l'atlas utilise le champs ``id_nomenclature_sensitivity`` de la table ``gn_synthese.synthese`` pour construire la vue ``atlas.vm_observations`` et remplir la géometrie adaptée en se basant sur référentiel géographique de GeoNature. Pour des raisons de performance et de lisibilité, GeoNature-atlas affiche le centroïde de la géometrie à laquelle l'observation est dégradée (le centroïde de communes si le niveau de diffusion est = 1 par exemple). Les données dont le niveau de diffusion est égal à 4 (aucune diffusion) ne sont pas affichées dans GeoNature-atlas. Non connecté à GeoNature2, la charge de la dégradation géographique est à la charge de l'administrateur des données.

Voir la nomenclature du "Niveaux de précision de diffusion souhaités" du SINP http://standards-sinp.mnhn.fr/nomenclature/5-niveaux-de-precision-de-diffusion-souhaites-niveauprecision-23-06-2016/.

Le niveau de floutage est déterminé et paramétrable depuis GeoNature via la table `gn_sensitivity.cor_sensitivity_area_type` qui fait une correspondance entre un niveau de sensibilité et un niveau de floutage. Pour des raisons de performances ce sont les mailles 1km, 5km et 10km qui sont utilisé pour flouter plutôt que la gémétrie des communes et des départements.

Une symbologie adaptée est fournie par défaut dans GeoNature-atlas (en vert les données dégradées, en bleu les données précises). Cette symbologie est customisable dans le fichier ``static/custom/maps-custom.js`` et permet plus largement de personnaliser l'affichage en fonction des informations renvoyées par la vue ``atlas.vm_observations`` (voir `<installation.rst#customisation-de-lapplication>`_).


Cas particulier du floutage et des fiches "zonage"
-----------------------------------------------------

L'atlas permet de créer des fiches par type de zonage (fiche par commune, par département etc...). Dans certains cas l'affichage d'observations et d'espèces sur ces fiches zonages peut fournir des informations plus précise que leur niveau de flouage souhaité. L'atlas exclue donc par défaut ces observations. Par exemple : observations dont le niveau de sensiblité exige une floutage au département ne sera pas affiché sur une fiche commune.
L'atlas permet également de créer des fiches zonages personnalisés (fiche d'un Parc Naturel régional par ex). Dans ce cas, il est nécessaire de remplir le champs `size_hierarchy` de la table `ref_geo.bib_areas_type`. Ce champs aide au calcul de l'affichage ou non des observations sensibles sur des niveau de zonage plus petit que leur géométrie de floutage.

