=========
CHANGELOG
=========

1.2.6.dev0 (unreleased)
-----------------------

**Nouveautés**

* Ajout du paramètre `BORDERS_COLOR` pour modifier la couleur des limites du territoire.

**Notes de version**

* Ajoutez le paramètre `BORDERS_COLOR` dans votre fichier `main/configuration/config.py` comme indiqué dans le fichier d'exemple (https://github.com/PnEcrins/GeoNature-atlas/blob/9272b14aeaf781f5311194411bee719579fb8b11/main/configuration/config.py.sample#L56-L57)

1.2.5 (2017-04-07)
------------------

**Nouveautés**

* Par défaut, ne plus limiter les observations à celles de l'organisme 2
* Correction mineure de CSS (Bloc "A voir en ce moment" de la page d'accueil)

1.2.4 (2017-03-07)
------------------

**Nouveautés**

* Compatibilité avec GeoNature 1.9.0 (multiprojection)
* Ajout du script SQL ``data/update_vm_observations.sql``, permettant de faciliter la mise à jour de la vue ``atlas.vm_observations`` 

**Notes de version**

* Exécutez le script ``data/update1.2.3to1.2.4.sql``
ATTENTION : vous ne devez exécuter ce script que si vous avez mis à jour la base de GeoNature en version 1.9.0.
Si vous utilisez l'atlas sans GeoNature, cette mise à jour n'est pas nécessaire.
* Si vous souhaitez adapter la vue matérialisée ``atlas.vm_observations`` contenant toutes les observations, vous pouvez l'adapter dans le script ``data/update_vm_observations.sql`` puis exécuter celui-ci.


1.2.3 (2017-02-23)
------------------

**Nouveautés**

* Améliorations de la documentation
* Ajout d'un champs ``diffusable`` (oui/non) dans la synthese de GeoNature, utilisable pour ne pas afficher les données sensibles dans l'atlas au moment de la création de la VM des observations. 

**Notes de version**

* Exécutez le script ``data/update1.2.2to1.2.3.sql`` pour ajouter la colonne ``diffusable`` à la table ``synthese.syntheseff``.
Si vous utilisez l'atlas sans GeoNature, cette mise à jour n'est pas nécessaire.
* Supprimez puis relancez la création de la vue ``atlas.vm_observations`` et les vues qui en dépendent en utilisant le script ``data/update_vm_observations.sql``.

1.2.2 (2016-12-14)
------------------

**Améliorations**

* Simplification des utilisateurs PostgreSQL et suppression du besoin d'un utilisateur super utilisateur. 
* Correction des tooltips qui ne fonctionnaient plus sur les pages suivantes dans les listes paginées
* Amélioration de la gestion des médias et possibilité de cacher l'URL hébergeant les médias.
* Correction de la création de ``atlas.vm_altitudes``

**Notes de version**

Si vous mettez à jour l'application, réalisez ces opérations en plus des opérations classiques (https://github.com/PnEcrins/GeoNature-atlas/blob/master/docs/installation.rst#mise-à-jour-de-lapplication) :

* Ajouter un paramètre ``modeDebug`` dans le fichier ``main/configuration/config.py`` : https://github.com/PnEcrins/GeoNature-atlas/blob/b055c834d0f5a030f5180fa46097931e4bbd1d93/main/configuration/config.py.sample#L4-L5
* Ajouter un paramètre ``REMOTE_MEDIAS_PATH`` et renommer le parametre ``URL_MEDIAS`` en ``REMOTE_MEDIAS_URL`` dans le fichier ``main/configuration/config.py`` : https://github.com/PnEcrins/GeoNature-atlas/blob/develop/main/configuration/config.py.sample#L124-L129

1.2.1 (2016-11-28)
------------------

**Améliorations**

* Prise en charge des contenus HTML dans les descriptions des articles
* Ajout du nom de la structure dans les ``<title>`` des pages
* Compléments sur les templates par défaut ``footer.html``, ``introduction.html`` et ``présentation.html``
* Ajout de templates par défaut ``credits.html`` et ``mentions-legales.html`` accessibles dans une modale depuis le footer
* Amélioration de l'installation et séparation de l'installation de l'environnement (``install_env.sh``) et de l'application (``install_app.sh``)
* Amélioration de l'affichage des milieux dans les fiches espèces
* Mise à jour mineure de l'installation automatique de la BDD
* Mise à jour de la documentation d'installation
* Usage des variables des types des médias dans le SQL des listes de taxons
* Meilleure gestion des images par défaut (photo principale et logos)
* Révision de tous les pictos des groupes (par @DonovanMaillard)
* Simplification de la barre verticale de navigation (sidebar)
* Mise à jour Leaflet 1.0.1 vers 1.0.2

**Corrections**

* Refonte complète de l'usage de jQuery.datatables dans les listes d'espèces (fiches communes, rangs taxonomiques et groupes)
* Réparation des tooltips et autres débugage dans les listes d'espèces
* Correction d'un bug sur la recherche dans la galerie photos
* Correction du z-index du spinner sur les fiches espèces
* Correction des caractères vides dans les URL et chemins des médias
* Autres corrections mineures

1.2.0 (2016-11-15)
------------------

**Evolutions**

* Mise à jour de Leaflet (version 0.7.7 à la version 1.0.1)

**Corrections**

* Correction du bug d'affichage de la protection et patrimonialité sur les fiches espèces. Fix #63
* Correction de l'installation automatique de la BDD (``$admin_pg`` désormais créé en superuser)
* Corrections et précisions dans la documentation

1.1.3 (2016-10-12)
------------------

**Améliorations**

* Ajout d'un lien vers les fiches espèces dans la galerie photo
* Correction de l'installation automatique de la BDD
* Complements documentation

1.1.2 (2016-10-07)
-----------------------

**Améliorations**

* Corrections minimes dans l'installation de la BDD
* Ajout de SHP exemples pour faciliter les tests de l'installation avec des données de tests

1.1.1 (2016-10-03)
------------------

**Améliorations**

* Optimisation du temps de chargement de la page d'accueil en améliorant la requête des statistiques par rang taxonomique
* Amélioration de l'installation sans GeoNature en permettant d'installer le schéma ``taxonomie`` de la BDD de TaxHub dans la BDD de GeoNature-atlas
* Intégration d'un exemple de table de données source (``synthese.syntheseff``) et de 2 observations exemple pour que l'installation automatisée fonctionne entièrement même sans GeoNature
* Compléments et corrections de la documentation

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
