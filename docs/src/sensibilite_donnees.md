# Guide de la gestion des données sensibles


GeoNature-atlas fournit un mécanisme de dégration des données sensibles basé sur les standards du SINP. Connecté à GeoNature version 2, l'atlas utilise le champs `id_nomenclature_sensitivity` de la table `gn_synthese.synthese` pour construire la vue `atlas.vm_observations` et afficher la géometrie adaptée en se basant sur référentiel géographique de GeoNature.
En mode "point", GeoNature-atlas affiche le centroïde de la géometrie à laquelle l'observation est dégradée (le centroïde de communes si le niveau de diffusion est = 1 par exemple). En mode maille, l'observation sera affichée tel que le niveau de d'affichage est défini dans la table de GeoNature `gn_sensitivity.cor_sensitivity_area_type` (voir plus bas).
Les données dont le niveau de diffusion est égal à 4 (aucune diffusion) ne sont pas affichées dans GeoNature-atlas.
Non connecté à GeoNature2, la charge de la dégradation géographique veillé à bien remplir le champs `id_nomenclature_sentivity`.

## Paramétrage de l'affichage des données sensibles

Il est possible de paramétrer le niveau d'affichage des données en fonction de leur niveau de sensibilité. Ce paramétrage se fait dans GeoNature dans la table `gn_sensitivity.cor_sensitivity_area_type`.
Par défault la table contient les données suivantes :

| Niveau de sensibilité | Niveau d'affichage |
| --------------------- | ------------------ |
| 0 = non sensible      | M1                 |
| 1                     | COM                |
| 2                     | M10                |
| 3                     | DEP                |


:::{tip}
- La colonne niveau de sensibilité est rempli avec l'id_nomenclature du niveau de sensibilité (http://standards-sinp.mnhn.fr/nomenclature/>5-niveaux-de-precision-de-diffusion-souhaites-niveauprecision-23-06-2016/)
- La colonne "niveau d'affichage" corespond id de type de zonage du ref_geo (`ref_geo.bib_areas_type.id_type`)
- La première ligne (0 = non sensible) correspond au niveau d'affichage d'une donnée non sensible dans un atlas en mode maille.
:::

Si vous souhaitez changer le niveau d'affichage en fonction du niveau de sensibilité, vous pouvez donc éditer cette table. Ceci nécessite ensuite de raffraichir les vues matéralisées (`refresh_materialized_view_data()`).

Sur la carte les observations sont classées dans différentes "couches" correspondant à chaque niveau de sensibilité.
Toutes ces couches sont ensuites affichables / masquables via le contrôleur de couche leaflet sur toutes les carte de l'atlas.

### Customisation du style en mode point

Pour le mode point une symbologie adaptée est fournie par défaut dans GeoNature-atlas (en vert les données dégradées, en bleu les données précises). Cette symbologie est customisable dans le fichier `static/custom/maps-custom.js` et permet plus largement de personnaliser l'affichage en fonction des informations renvoyées par la vue `atlas.vm_observations`.

## Cas particulier du floutage et des fiches "zonage"

L'atlas permet de créer des fiches par type de zonage (fiche par commune, par département etc...).

Dans certains cas l'affichage d'observations et d'espèces sur ces fiches zonages peut fournir des informations plus précises que leur niveau de floutage souhaité. L'atlas exclue donc par défaut ces observations. Par exemple : les observations dont le niveau de sensiblité exige une floutage au département ne sera pas affiché sur une fiche commune. Cette information est déduit du champs :`is_valid_for_display` de la vm `atlas.vm_cor_area_synthese`

L'atlas permet également de créer des fiches zonages personnalisés (fiche d'un Parc Naturel régional par ex). Dans ce cas, il est nécessaire de remplir le champs `size_hierarchy` de la table `ref_geo.bib_areas_type`. Ce champs aide au calcul de l'affichage ou non des observations sensibles sur des niveau de zonage plus petit que leur géométrie de floutage.
