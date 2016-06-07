# GeoNature-atlas

Atlas WEB dynamique Faune-Flore basé sur les données présentes dans la synthèse de GeoNature.

Il permet de générer dynamiquement des fiches espèces avec des données calculées automatiquement (cartes de répartition, répartition altitudinale et phénologique, communes, secteurs, observateurs...) ainsi que des données saisies pour chaque espèce (photos, description...). 

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

L'API de GeoNature-atlas se servira directement dans des vues. Ainsi chacun pourra personnaliser ses vues en fonction des besoins et des différences dans les tables. 

L'ensemble des vues seront regroupées dans un schéma spécifique « atlas », ce qui laisse la possibilité à terme de les remplir avec autre chose que GeoNature.
