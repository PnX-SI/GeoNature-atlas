=======================================
AFFICHAGE DE COUCHES SIG ADDITIONNELLES
=======================================

Config : pages
==============

- liste des pages de l'application sur laquelle la couches SIG doit être disponible
- valeurs possibles : 'home', 'species', 'commune'
- si la propriété ``pages`` n'est pas présente la couche SIG est disponible sur toutes les pages

Config : groups2_inpn
=====================

- listes des groupes 2 INPN pour lesquels la couches SIG est disponible
- a un effet uniquement pour la page 'species'
- si la propriété ``groups2_inpn`` n'est pas présente la couche SIG est disponible pour tous les groupes taxonomiques

Listes des valeurs possibles pour ``groups2_inpn`` : 'Acanthocéphales', 'Amphibiens', 'Angiospermes', 'Annélides', 'Arachnides', 'Ascidies', 'Autres', 'Bivalves', 'Céphalopodes', 'Chlorophytes et Charophytes', 'Crustacés', 'Diatomées', 'Entognathes', 'Gastéropodes', 'Gymnospermes', 'Hépatiques et Anthocérotes', 'Hydrozoaires', 'Insectes', 'Lichens', 'Mammifères', 'Mousses', 'Myriapodes', 'Nématodes', 'Némertes', 'Ochrophytes', 'Octocoralliaires', 'Oiseaux', 'Plathelminthes', 'Poissons', 'Ptéridophytes', 'Pycnogonides', 'Reptiles', 'Rhodophytes', 'Scléractiniaires'

Comment contrôler la profondeur de l'affichage pour chaque couche ?
===================================================================

Fonctionnement par défaut :

- couches WMS vont dans le ``tile pane`` avec un z-index de 1
- comportement CSS par défaut (z-index identiques) : la dernière couche WMS activée se met au-dessus des autres couches WMS
- couches arcgisMapService sont placées sur ``overlay pane`` et utilisent un mécanisme ``autoZIndex`` par défaut
- même comportement que les couches WMS : dernière couche Arcgis activée se met au-dessus des autres couches Arcgis
- Leaflet place ``overlay pane`` au-dessus du ``tile pane`` : les couches Arcgis apparaissent toujours au-dessus des couches WMS

Les options suivantes permettent de contrôler finement les profondeurs des couches :

- ``pane`` : pour changer la destination d'une couche. Par exemple : ``'pane': 'overlayPane'`` pour une couche WMS
- ``zIndex`` : spécifie le z-index de la couche. Par exemple : ``'zIndex': 30``

Remarques :

- les z-index des couches sont pris en compte relativement aux couches du même pane (comportement CSS)
- Leaflet place les couches points ou mailles de gn-atlas au z-index 200 dans le ``overlay pane``

Sources
=======

- basé sur le [plugin Leaflet layer-tree-control](https://github.com/ignaciofagian/L.LayerTreeControl), license MIT
- utilise la lib Leaflet [esri-leaflet](https://developers.arcgis.com/esri-leaflet/) sous licence Apache ([lien Github](https://github.com/Esri/esri-leaflet))
- le pictogramme pour le bouton provient de https://www.svgrepo.com/svg/451034/layer-polygon sous licence [CC0](https://fr.wikipedia.org/wiki/Licence_CC0)
