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

Sources
=======

- basé sur le [plugin Leaflet layer-tree-control](https://github.com/ignaciofagian/L.LayerTreeControl), license MIT
- utilise la lib Leaflet [esri-leaflet](https://developers.arcgis.com/esri-leaflet/) sous licence Apache ([lien Github](https://github.com/Esri/esri-leaflet))
- le pictogramme pour le bouton provient de https://www.svgrepo.com/svg/451034/layer-polygon sous licence [CC0](https://fr.wikipedia.org/wiki/Licence_CC0)
