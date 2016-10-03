=========
CHANGELOG
=========

1.1.2.dev0 (unreleased)
-----------------------

1.1.1 (2016-10-03)
------------------

**Amélioriations**

* Optimisation du temps de chargement de la page d'accueil en améliorant la requête des statistiques par rang taxonomique
* Amélioration de l'installation sans GeoNature en permettant d'installer le schéma ``taxonomie`` de la BDD de TaxHub dans la BDD de GeoNature-atlas
* Intégration d'un exemple de table de données source (``synthese.syntheseff``) et de 2 observations exemple pour que l'installation automatisée fonctionne entièrement même sans GeoNature
* Compléments et corrections de la documntation

1.1.0 (2016-09-30)
------------------

Dernier jour de stage de Théo Lechemia, développeur initial de GeoNature-atlas

**Nouveautés**

* Ajout d'une liste des espèces observées par groupe
* Ajout des icones sur les fiches des espèces qui sont patrimoniales et/ou protégées

**Corrections**

* Correction de l'installation
* Compléments dans la documentation
* Autres corrections mineures (CSS, lightbox, statistiques)


1.0.0 (2016-09-28)
------------------

Première version complète et fonctionnelle de GeoNature-atlas

**Fonctionnalités principales**

* Installation automatisée (avec GeoNature ou sans) de l'environnement, des données SIG (mailles, limite du territoire et communes) et de la BDD
* Page d'accueil dynamique et paramétrable avec introduction, statistiques globales et par rang taxonomique, carte et liste des 100 dernières observations et taxons les plus vues dans la période en cours (toutes années confondues)
* Recherche parmis tous les taxons observés et leurs synonymes
* Fiches espèces avec carte des observations (par maille ou point selon la configuration) filtrables par années, graphiques des observations par classes d'altitudes et par mois, affichage des médias (photos, audios, vidéos, liens et PDF), gestion des descriptions
* Récursivité sur les fiches espèces pour agglomérer les observations au niveau de l'espèce + des éventuelles niveaux inférieurs (sous-espèces, variétés...)
* Gestion d'un glossaire permettant d'afficher dynamiquement la définition des termes techniques
* Fiche par commune affichant la liste des espèces observées sur la commune, une carte des 100 dernières observations et la possibilité d'afficher la carte des observations d'une espèce sur la commune
* Fiche par rang taxonomique affichant la liste des espèces observées dans ce rang
* Possibilité de configurer à quel rang taxonomique on passe des fiches à la liste des espèces du rang
* CSS et textes entièrement customisables
* Généricité pour se connecter à n'importe quelle BDD comportant des observations basées sur TAXREF

**A venir**

* Finition de la galerie photo (liens vers fiches espèce)
* Fiche par groupe
* Gestion forcable des types d'affichage cartographique en mode point (mailles, clusters ou points à n'importe qu'elle échelle)
* CSS des listes d'espèces (communes et rangs taxonomiques)