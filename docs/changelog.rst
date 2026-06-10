=========
CHANGELOG
=========

2.0.0 (Unreleased)
------------------

- Elargissement des fiches communes en fiches zonages et enrichissement de leur contenu
- Affiche des statuts de protection et de conservation depuis la BDC statuts
- Floutage des données sensibles en mode Maille

🚀 **Nouveautés**

- Support de Debian 13. Abandon du support de Debian 11
- Ajout du floutage des données sensibles en mode Maille (#571 par @juggler31 et @submarcos)
- Possibilité de remplacer la carte des dernières observations de la page d'accueil par une carte du territoire avec toutes les observations de l'atlas (paramètre ``AFFICHAGE_TERRITOIRE_OBS``) (#615 par @juggler31)
- Changement de la notion de "commune" en notion de "territoire". Possibilité de faire des fiches "territoire" sur tous les zonages du ref_geo (départements, réserves, ZNIEFF etc...) avec le paramètre ``type_code`` du fichier ``settings.ini`` (#545 par @juggler31)
- Ajout d'un graphique de provenance des données par organisme sur les fiches espèce (si ``ORGANISM_MODULE=True``) (#538 par @juggler31)
- Ajout de graphiques sur les fiches territoire (possibilité d'afficher/masquer les statistiques de comparaison avec tout le territoire de l'atlas : ``AFFICHAGE_TOUT_TERRITOIRE_GRAPH`` et avec les espèces patrimoniales : ``DISPLAY_PATRIMONIALITE``) (par @juggler31)
- Ajout de la possibilité d'afficher un texte de présentation sur chaque fiche territoire, basé sur le nouveau champs texte de la table ``ref_geo.l_areas`` (#507 par @juggler31)
- Ajout de "liens focus" sur les fiches taxons. Cette fonctionnalité permet par exemple de mettre en avant des démarches ou des ressources additionelles sur un taxon : un lien vers une plateforme de contribution collaborative, un lien vers une fiche détaillée sur l'espèce etc... Voir le paramètre ``TYPES_MEDIAS_LENS_FOCUS`` (par @marcantoinedupre)
- Ajout des statuts de conservation sur les fiches espèce. Le paramètre de configuration ``GROUPES_STATUTS`` permet de grouper et de filtrer les statuts que l'on souhaite afficher. Le template ``custom/templates/statuts.html`` permet de customiser l'affichage des statuts (customisation avancé, à modifier avec précaution) (par @marcantoinedupre, @pbarille et @amandine-sahl)
- Ajout de la notion d'espèce menacée et de graphiques associés sur les fiches territoire. La notion de menace est basé sur les listes rouges. Un taxon est considéré comme menacé s'il est sur une des liste suivantes : VU, EN, CR, CR* (#669 @Orangetine) 
- Ajout de filtre par group2_inpn et par statuts (protégé, menacé, patrimonial) sur toutes les listes de taxons (#607 #651 par @Orangetine et @TheoLechemia)
- Possibilité d'exporter les listes de taxons en csv et PDF (#650 @Orangetine @TheoLechemia)
- Le statut d'espèce protégée n'est plus calculé à partir d'un attribut TaxHub mais à partir de la BDC statuts (#135)
- Déplacement des fichiers de personnalisation ``sample`` dans le dossier ``static/sample/``. Le dossier ``static/custom/`` est à utiliser pour surcoucher les fichiers de ``static/sample/``.
- Ajout d'un gestionnaire de couches cartographiques supplémentaires (WMS et geojson) dans le paramètre ``COUCHES_SIG`` (#572 @juggler31)
- Ajout du plugin Nominatim permettant une recherche d'adresse sur les cartes de la page d'accueil et des fiches territoire, désactivé par défaut avec le paramètre ``SEARCH_NOMINATIM`` (#716 @juggler31)
- Nouvel affichage des tooltips lorsqu'on clique sur une maille (#721 @juggler31)
- Possibilité de masquer la page de la gallerie photo  via le paramètre ``AFFICHAGE_GALERIE_PHOTO`` (#703 @lpofredc)
- Ajout de la possibilité de configurer la table / vue source des données en entrée de l'atlas (#749) (voir la rubrique "Configuration des données d'observations présente dans l'atlas" dans la documentation sur la configuration )
- Les fichiers de langues sont dorénavant surcouchables (voir section "Customisation des textes et labels via la surcouche du multiligue" dans la documentation sur la configuration)
- Refonte du style des pictos de patrimonialité, protection et menace. Les 3 icones sont maintenant surcouchables (##753 @TheoLechemia)
- Possibilité d'ajouter des textes sur les éléments du menu latéral sidebar (#729 @juggler31)
- Ajout du paramètre ``LIMIT_POINT_MAILLE`` qui permet de définir le seuil à partir duquel on affiche les données en mode maille sur un atlas en mode point (défaut 500 observations)
- Le paramètre ``drop_apps_db`` du fichier settings.ini est déprécié. Le script ``install_db.sh`` supprime uniquement le schéma ``atlas`` si le script ``install_db.sh`` est lancé sur une base déja existante.
- Ajout d'une fonction pour rafraichir uniquement les attributs et les médias associés aux taxons (``atlas.refresh_materialized_view_taxon_attr_and_media``)
- Ajout de la traduction de l'interface en tchèque (#731 par @trendspotter)
- Les paramètres de l'URL de la fiche territoire était ``url_for('main.ficheCommune', insee=05090)`` et devient ``url_for('main.area', id_area=XXXXXX)``
- Pagination des listes
- Ajout de statistiques sur la fiche de "zonage" (#540 @juggler31)
- Corrections diverses (@lpofredc et @xavyeah39)
- Ajout des paramètres suivants : DISPLAY_ZONING_PAGE_SENSIBILITY_MESSAGE, TYPES_MEDIAS_LENS_FOCUS, COUCHES_SIG, LIMIT_POINT_MAILLE, AFFICHAGE_MENACE, AFFICHAGE_TAB_AREA_GENERAL_PRESENTATION, AFFICHAGE_TAB_AREA_OBS_ESPECES, ITEMS_PER_PAGE, AFFICHAGE_TERRITOIRE_OBS, AFFICHAGE_LABEL_SIDEBAR, AFFICHAGE_GALERIE_PHOTO, SEARCH_NOMINATIM, TYPE_TERRITOIRE_SHEET, AREA_PARENTS_TYPE, AFFICHAGE_GRAPH_PHENOLOGIE, ALTITUDE_RANGES, AFFICHAGE_TOUT_TERRITOIRE_GRAPH, AFFICHAGE_GRAPH_PROVENANCE_DONNEE, AFFICHAGE_STATUTS, GROUPES_STATUTS, TEMPLATE_MAIN_COLOR, TEMPLATE_SECOND_COLOR, COLOR_STACKED_BAR_CHARTS, COLOR_PIE_CHARTS, COULEUR_CONTOUR_MAILLE


**Documentation**

- Déploiement automatique de la documentation avec Sphinx, désormais disponible sur https://pnx-si.github.io/GeoNature-atlas/ (#764 par @lpofredc)
- Ajout d'une section FAQ
- Ajout d'un fichier de contribution (Contributing.md)

👨‍💻 **Développement**

- Mise à jour de Bootstrap 4 à 5 (#667 par @Orangetine et @jpm-cbna)
- Mise à jour de SQLAlchemy 1.4 à 2.0 (#663 par @Orangetine)
- Mise à jour de Leaflet 1.6.0 à 1.9.4 (#637 par @Orangetine)
- Mise à jour des dépendances Python et Javascript
- Amélioration des scripts bash d'installation et de l'installation Docker (par @jpm-cbna et @TheoLechemia)
- Ajout de tests Python automatisés (@TheoLechemia)

⚠️ **Notes de version**

Pour cette version 2.0.0, il ne s'agit pas d'une mise à jour, mais d'une réinstallation complète. Suivez la documentation d'installation (téléchargement du code, installation des dépendances systèmes, installation de la base de données et installation de l'application). La base de données de l'atlas doit être complétement réinstallée (renseigner un nouveau nom de base de données dans le paramètre ``db_name`` du fichier ``settings.ini`` ou supprimer la base de données actuelle).
Veillez à avoir des sauvegardes si vous souhaitez revenir en arrière.

Rappatriez les fichiers suivants au même emplacement : 

- atlas/static/custom.css
- atlas/static/glossaire.json
- atlas/static/territoire.json

⚠️  La version 2.16 de GeoNature est necessaire pour installer cette version.


❗ BREAKING CHANGE :

- Le floutage (et l'exclusion des données) ne s'appuie plus sur les niveaux de diffusion, mais uniquement le niveau de sensibilité. 
- Quand l'atlas est connecté à une BDD GeoNature, on prend par défaut tout le contenu de la table ``gn_synthese.synthese`` (#749). Si besoin, il est possible de filtrer les données en amont (voir paramètre `observation_data_source`)
- On n'affiche plus par défaut la couche du territoire sur la carte. Si vous souhaitez afficher votre territoire ou tout autre couche ou zonage sur les cartes, utilisez le nouveau mécanisme plus générique et global de couches additionnelles (#572), paramètre ``COUCHES_SIG``.
- Le passage à Bootstrap 5 nécessite de revoir le contenu des templates personnalisés (``custom/templates``). Il est necessaire de repartir des templates fournis dans ``atlas/static/sample/templates`` et d'adapter leur contenu.
- La fonction ``pointDisplayOptionsFicheCommuneHome`` qui permet de configurer le style cartographique en mode point devient ``customizeMarkerStyle``
- Les paramètres ``BORDERS_COLOR``, ``BORDERS_WEIGHT`` pour styliser le coutour du territoire sont dépréciés. Utilisez le paramètre ``COUCHES_SIG`` et l'attribut ``style`` de ce paramètre pour configurer le style de la couche (voir l'exemple dans ``config.py.example``)
- Les variables css ``--main-color`` et ``--second-color`` utilisées dans la surcouche css sont dépreciées et à retirer du fichier ``static/custom/custom.css``. Utilisez les variables de configuration (config.py) ``TEMPLATE_MAIN_COLOR`` et ``TEMPLATE_SECOND_COLOR`` à la place.
- Le paramètre ``PATRIMONIALITE`` est déprécié. Utilisez la surcouche de langue si vous souhaitez modifier ce terme (id : ``patrimonial``, ``patrimonial.plural`` et ``this.taxa.is.patrimonial``)
- Régression : Suppression de ``MASK_STYLE`` qui permettait d'appliquer un masque sur la carte autour du territoire
- Régression : Suppression du paramètre ``PATRIMONIALITE`` qui permettait de s'appuyer sur un autre attribut TaxHub, de définir ses valeurs et icones.
- Déplacement des fichiers de personnalisation ``sample`` dans le dossier ``static/sample/``. Le dossier ``static/custom/`` est à utiliser pour surcoucher les fichiers de ``static/sample/``.
- Config des types de statuts à afficher.
- Config des types de zonage (avec possibilité de renommer "Territoires" en "Communes" avec surcouche de langue, si on ne garde qu'un type de zonage)




1.7.3 (2025-09-20)
------------------

🐛 **Corrections**

* Gain de performance sur la vue ``synthese.syntheseff`` (#675 par @lpofredc)
* Ajout de ``st_makevalid(geom)`` sur la création de la vue ``atlas.t_layer_territoire`` (#680 par @lpofredc)

⚠️ **Notes de version**

- Exécutez le script SQL de mise à jour de la BDD : https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/update/update_1.7.2to1.7.3.sql

1.7.2 (2025-09-17)
------------------

🐛 **Corrections**

* Correction du script de migration ``1.6.1to1.7.0.sql``
* Correction du chemin vers les audio et vidéo hebergés depuis TaxHub (@gildeluermoz)

1.7.1 (2025-09-02)
------------------

🚀 **Nouveautés**

* Possibilité d'utiliser la date courante dans les templates via la variable ``now`` (#660 par @jpm-cbna)

🐛 **Corrections**

* Correction de l'image docker (#660 par @jpm-cbna)
* Diverses corrections mineures d'installation

1.7.0 (2025-08-08)
------------------

- Nécessite Debian 11 ou 12.
- Compatible avec GeoNature 2.15.0 (ou plus) et TaxHub 2.0.0 (ou plus). Fonctionne aussi avec les versions précédentes de GeoNature et TaxHub mais sans filtrer les éventuels médias supprimés.

🚀 **Nouveautés**

- Ajout du support de Debian 12. Suppression du support de Debian 9 et 10 (#582 par @juggler31, @marcantoinedupre, @submarcos)
- Ajout de tests automatisés pour tester l'installation des dépendances Python (#582 par @juggler31)
- Nettoyage et simplification des scripts d'installation
- Suppression du support des installations sans TaxHub (#582 par @amandine-sahl)
- Suppression des installations sans ``ref_geo`` (par @TheoLechemia)
- Refonte de l'intégration d'outils de suivi de fréquentation (Google analytics, Matomo ou autre) en lien avec la mise en conformité RGPD (#527 @juggler31, #499 par @andriacap)
- Ajout de la librairie Orejime pour recueillir le consentement de l'utilisateur sur l'utilisation des cookies (#527 @juggler31)
- Ajout de la possibilité d'ajouter un lien dans le pied de page (footer) vers une modale précisant la politique des données personnelles, activable ou non avec le paramètre ``AFFICHAGE_RGPD`` (#527 par @juggler31)
- Ajout du support des cd_nom négatifs sur les fiches espèces et les API (#616 par @andriacap)
- Ajout des paramètres ``AFFICHAGE_GRAPH_PHENOLOGIE`` et ``AFFICHAGE_GRAPH_ALTITUDES`` pour afficher/masquer les graphiques de phénologie et d'altitude sur les fiches espèces (#568 par @gildeluermoz)
- Affichage des dates au format "court" et selon la langue du navigateur (#512 et #631 par @geobrun et @xavyeah39)
- Possibilité de personnaliser les attributs TaxHub du bloc "Informations espèce" sur les fiches espèces (#412 par @jpm-cbna)
- Ajout de la possibilité d'ajouter un lien externe et d'utiliser un picto sous forme d'image dans la barre de navigation latérale (#520 par @geobrun)
- Compactage des informations dans les blocs de bas de page sur les fiches espèce (#601 par @bruhnild)
- Amélioration du responsive design (#609 par @bruhnild)
- Amélioration de la recherche par espèces, insensible aux accents et mieux formatée (#532 par @jpm-cbna)
- Suppression de l'affichage des balises ``<i></i>`` dans les zones de recherche de taxon (#405 par @jpm-cbna)
- Amélioration de la recherche par commune : mots tronqués, sans accent (#531 par @jpm-cbna)
- Prise en charge du formatage markdown des contenus des attributs de description des espèces provenant de TaxHub (#413 par @jpm-cbna)
- Amélioration des performances des requêtes des fiches espèces en forçant l'utilisation des index de la BDD (#516 par @jpm-cbna)
- Amélioration du chargement des mailles des observations sur les fiches espèces en optimisant ``atlas.vm_observations_mailles`` (#518 par @jpm-cbna et @juggler31)
- Mise à jour des dépendances Python (Flask version 2 à 3, marshmallow 3 à 4...)
- Possibilité de définir l'option ``fetch_size`` des connexions de BDD en Foreign data wrapper (#657 par @jpm-cbna)

🐛 **Corrections**

- Correction de l'affichage des observations par maille sur la carte des fiches "Commune" (#453 par @jpm-cbna)
- Correction de l'affichage par maille sur les cartes des fiches "Commune" (#533 par @jpm-cbna)
- Correction et amélioration de l'affichage de la fenêtre listant les sous-taxons agrégés sur les fiches espèces (#558 par @jpm-cbna)
- Prise en charge des cd_nom négatifs (#616 par @andriacap)
- Correction du lien vers le statut INPN des taxons protégés sur la page organisme (#578 par @marcantoinedupre)
- Correction du "lazy-loading" des images sur les page HTML (#590 par @submarcos)
- Suppression de la possibilité de masquer l'URL de TaxHub quand on récupère un média et du paramètre associé ``REMOTE_MEDIAS_PATH`` (#642 par @TheoLechemia)
- Suppression d'erreurs javascript sur la page d'accueil (#403 par @jpm-cbna)
- Prise en charge complète du paramètre ``SPLIT_NOM_VERN`` (#514 par @xavyeah39)

👨‍💻 **Développement**

- Ajout d'un Makefile afin de faciliter les développements (#576 par @juggler31)
- Ajout de la possibilité de créer des images Docker sur un fork du dépôt (#585 par @submarcos)
- Correction du fichier ``.gitignore`` (#554 par @sfermigier)

⚠️ **Notes de version**

- Il est désormais possible d'installer ou mettre à jour GeoNature uniquement sur Debian 11 et 12.
- En raison d'un conflit d'URL avec le mode multiligue les "pages statiques" (voir paramètre `STATIC_PAGES`) sont désormais préfixées de "/static_pages/"
- Suppression de la possibilité d'installer GeoNature-atlas à partir de couches shapefile. Tous les zonages et les mailles sont basés sur le ``ref_geo`` fourni par GeoNature ou TaxHub. Il est maintenant obligatoire de disposer de TaxHub (dans GeoNature ou à part) pour déployer GeoNature-atlas. Alimenter GeoNature-atlas avec GeoNature reste optionnel.
- Veuillez vous référer à la documentation concernant le RGPD et le consentement du recueil de cookies : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/cookies_rgpd.rst. Ces fonctionnalités sont utiles uniquement si vous avez mis en place le recueil de cookies nécessitant le consentement de l'utilisateur (statistiques de fréquentation avec Google Analytics par exemple).
- Le paramètre ``ID_GOOGLE_ANALYTICS`` et l'intégration native d'un script Google analytics sont dépréciés. Se référer à la documentation sur le RGPD ci-dessus si vous suivez la fréquentation de votre GeoNature-atlas avec Google Analytics et devez mettre en place le consentement RGPD. Attention, tous les utilisateurs qui ne valideront pas le consentement ne seront pas comptabilisés et les chiffres de fréquentation seront donc plus faibles que la réalité. Pour suivre la fréquentation d'un portail GeoNature-atlas, il est donc conseillé de plutôt utiliser des solutions compatibles RGPD sans collecte de cookies et donc sans nécessiter de demande consentement, comme Matomo.
- Le paramètre ``REMOTE_MEDIAS_PATH`` est deprecié, seul ``REMOTE_MEDIAS_URL`` permet de construire l'URL des médias "locaux" (dont le champs ``chemin`` est rempli).
- Pour ajouter un lien vers la politique de gestion des données personnelles dans le pied de page (footer), répercuter les `évolutions <https://github.com/PnX-SI/GeoNature-atlas/pull/574/files#diff-05964f85b0bb6f2d285f98fe1e3a56d9343b8a740ddd8c7e6ac85cfd611f62bb>`_ du template de footer dans votre fichier ``custom/templates/footer.html``, copier le fichier `custom/templates/personal-data.html.sample <https://github.com/PnX-SI/GeoNature-atlas/blob/develop/atlas/static/custom/templates/personal-data.html.sample>`_ en ``custom/templates/personal-data.html`` (``cp custom/templates/personal-data.html.sample custom/templates/personal-data.html``), puis adapter le contenu du fichier ``custom/templates/personal-data.html`` à votre contexte
- Rajouter le paramètre ``taxhub_displayed_attr`` dans le fichier ``settings.ini`` si vous devez réinstaller la BDD (https://github.com/PnX-SI/GeoNature-atlas/blob/1.7.0/atlas/configuration/settings.ini.sample#L92)

Si vous mettez à jour GeoNature-atlas, suivez la procédure classique de MAJ décrite dans : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/installation.rst#mise-%C3%A0-jour-de-lapplication

- Ajoutez l'extension ``unaccent`` à la base de données ``CREATE EXTENSION IF NOT EXISTS unaccent SCHEMA "public";`` (#531, #532)
- Exécutez le script SQL de mise à jour de la BDD : https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/update/update_1.6.1to1.7.0.sql (Attention à remplacer l'utilisateur ``geonatatlas`` dans les GRANT à la fin du fichier si vous avez changé l'utilisateur lecteur ``user_pg`` dans le fichier ``settings.ini``)

Vous pouvez supprimer les paramètres suivants du fichier ``settings.ini`` :

- ``use_ref_geo_gn2``
- ``install_taxonomie``
- ``communes_shp``
- ``colonne_insee``
- ``colonne_nom_commune``
- ``limit_shp``
- ``metropole``
- ``taillemaille``
- ``chemin_custom_maille``
- ``taxhub_release``

1.6.1 (2023-10-16)
------------------

🚀 **Nouveautés**

- Possibilité de surcoucher les fichiers du dossier ``static`` en les plaçant avec le même nom dans le dossier ``custom`` (#496)
  - Par exemple pour surcoucher le pictogrammes des mammifères, mettre le votre dans ``custom/images/picto_Mammiferes.png``
- Possibilité de customiser le fichier ``navbar.html`` (déplacé dans le dossier ``static/custom/templates``) (#496)
- Ajout d'un linter pour le code python (``black``)

⚠️ **Notes de version**

- Si l'application n'est pas à la racine du serveur (par exemple avec ``/atlas``), la configuration Apache est à modifier et devient :

::
    <Location /atlas>
        ProxyPass  http://127.0.0.1:8080/atlas
        ProxyPassReverse  http://127.0.0.1:8080/atlas
    </Location>

- Copier le fichier ``navbar.html`` dans le dossier ``atlas/static/custom/templates/`` :


::
    cp atlas/static/custom/templates/navbar.html.sample atlas/static/custom/templates/navbar.html



1.6.0 (2023-09-15)
------------------

🚀 **Nouveautés**

- Ajout du paramètre ``DISPLAY_OBSERVERS`` permettant de masquer les observateurs des fiches espèces (#439 par @mvergez)
- [Docker] Ajout d'un fichier ``Dockerfile`` permettant de dockeriser GeoNature-atlas (#470)
- [Docker] Ajout d'une Github action publiant automatiquement les images Docker de GeoNature-atlas
- [Docker] Ajout des scripts ``docker_startup.sh`` et ``docker_install_atlas_schema.sh`` (sera exécuté au démarrage du container si la variable d'environnement ``ATLAS_INSTALL_SCHEMA`` est à  ``true``) (#470)
- Possibilité de définir le chemin vers le fichier de config avec ``ATLAS_SETTINGS`` (par défaut ``atlas/configuration/config.py``) (#470)
- Possibilité de définir le chemin vers le dossier des templates avec ``ATLAS_TEMPLATE_FOLDER`` (par défaut ``.``) (#470)
- Possibilité de définir le chemin vers le dossier des templates avec ``ATLAS_STATIC_FOLDER`` (par défaut ``atlas/static``) (#470)
- Gestion du proxy avec ``ProxyFix`` (#470)
- Mise à jour de Flask en version 2 et de nombreuses dépendances Python (#470)

🐛 **Corrections**

- Corrections linguistiques (#383 par @Splendens)
- Correction d'une traduction (#433 par @mvergez)
- Harmonisation et correction des fiches organismes (#382, #384 par @Splendens)
- Correction de l'affichage des pictos des groupes 2 INPN quand leur nom contient un accent (#380 par @Splendens)
- Amélioration de l'affichage des logos des organismes sur la page d'accueil (#381 par @Splendens)
- Affichage de lb_nom en italique (#387 par @Splendens)
- Affichage HTML du titre du média principal dans les fiches espèce (#420 par @joelclems)
- Correction du scroll infini de la galerie photo (#430 par @mvergez)
- Correction des liens vers les fiches espèces dans la galerie photo
- Correction du lien vers les fiches espèces dans la galerie photo (#459 par @jpm-cbna)
- Correction du bouton de tri (aléatoire ou nombre d'observation) dans la galerie photo
- Amélioration du lien vers la fiche d'un taxon depuis la galerie photo (#432 par @mvergez)
- Correction de l'affichage de la liste des taxons sur les fiches communes (#445 par @mvergez)
- Prise en compte des cas où le SRID est différent de 2154 lors de la création de ``atlas.vm_mailles_territoire`` (#417 par @joelclems)
- Harmonisation de l'affichage du picto group2_inpn (#424, #425, #426, #427, #429 par @MissT)
- Affichage en double de la légende quand le slider était manipulé (#452 par @mvergez)
- Exclusion des médias supprimés dans la vue ``vm_medias`` (#458 par @jpm-cbna)
- Spécification du port de base de données dans le script ``install_db.sh`` (#422 par @geobrun)
- Correction des photos lors du scroll dans les fiches des communes (#448 par @mvergez)
- Affichage cartographique sur la page "Recherche avancée" (#486)
- Support des cd_ref négatifs

🐛 **Optimisations**

- Optimisation de la requête de sélection des "Nouvelles espèces observées" (#455 par @andriacap)
- Mise en cache des statistiques de la page d'accueil (#400 par @TheoLechemia)
- Optimisation et ajout d'index sur la vue ``atlas.vm_cor_taxon_organism`` (#463 par @jpm-cbna)
- Redirection des URL des fiches espèces des synonymes vers les noms de référence (#388 par @jpm-cbna)
- Suppression des requêtes inutiles sur la page d'accueil (#275 par @jpm-cbna)
- Nettoyage et optimisation du code (#395, #407, #396, #394 par @jpm-cbna)
- Ajout du paramètre permettant de recharger automatiquement les templates (#431 par @mvergez)

⚠️ **Notes de version**

Si vous mettez à jour GeoNature-atlas :

- Exécutez le script SQL de mise à jour de la BDD : https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/update/update_1.5.2to1.6.0.sql
- Dans le fichier de configuration ``config.py``, changez le nom du paramètre ``database_connection`` en ``SQLALCHEMY_DATABASE_URI``
- Si vous utilisiez le paramètre ``ANONYMIZE``, celui-ci est à remplacer par ``ORGANISM_MODULE`` et ``DISPLAY_OBSERVERS`` qui permettent d'afficher ou non indépendamment les organismes et les observateurs
- Suivez la procédure classique de mise à jour de l'application

1.5.1 (2021-12-06)
------------------

🐛 **Corrections**

- Ajout de l'utilisation de ``nvm`` dans le script ``install_app.sh`` (par @gildeluermoz)
- Nettoyage de la documentation (par @gildeluermoz)
- Mise à jour de la version du schéma ``taxonomie`` pour une installation sans GeoNature (par @gildeluermoz)

⚠️ **Notes de version**

Si vous mettez à jour GeoNature-atlas :

- Vous pouvez passer directement à cette version, mais en suivant les notes de versions intermédiaires
- Télécharger et installer ``nvm`` :

::

    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

- Suivez la procédure classique de mise à jour de l'application.

1.5.0 (2021-12-02)
------------------

🚀 **Nouveautés**

**1. Affichage des organismes (#291 par @corentinlange)**

- Affichage des organismes activable avec le paramètre ``ORGANISM_MODULE`` (désactivé par défaut) (#325)
- Affichage des organismes ayant fourni des données d'une espèce dans la fiche espèce (#315)
- Intégration du bandeau organisme sur la page d'accueil (#245 par @Splendens)
- Création de fiches organismes, avec logo, nom, nombre de données, espèces les plus observées et familles de taxons observés par un organisme (#291)

**2. Multilingue (#175 par @TheMagicia et @corentinlange)**

- Mise en place du multilingue (activable avec le paramètre ``MULTILINGUAL``) avec les fichiers de langue de traduction de l'interface en français, anglais et italien
- Langue détectée automatiquement en fonction de la langue du navigateur
- Possibilité pour l'utilisateur de basculer sur une autre langue disponible
- Optimisation du multilingue pour le référencement par les moteurs de recherche
- Redirection automatique des URL sans clé de langue pour le référencement et les anciennes URL
- Documentation (``docs/multilingual.rst``)

**3. Bootstrap 4 (#233 par @lpofredc)**

- Mise à jour de Bootstrap version 3 à 4 (#230)
- Remplacement de la police d'icônes Glyphicon par Font Awesome
- Correction de l'absence de la hiérarchie sur les fiches taxons
- Restructuration des templates (avec ``includes`` & ``blocks``) et mutualisation des parties partagées
- Refonte de la page commune, notamment en fixant la carte et en ne scrollant que dans la liste (#79)
- Remplacement de la librairie des graphiques morris/D3 par chart.js (#164)
- Ajout d'un fichier ``sitemap.xml`` à la racine de l'application, autogénéré pour optimiser le référencement par les moteurs de recherche (#44)
- Ajout d'un fichier ``robots.txt`` à la racine de l'application, à partir d'un template customisable, pour indiquer aux moteurs de recherche les pages qu'ils peuvent indexer ou non (#223)
- Utilisation des zonages activés uniquement dans le ``ref_geo`` (``enable = true``)
- Possibilité de customiser en CSS la couleur des contours des objets sur les cartes (mailles, territoire, zonages)
- Corrections de la hiérarchie taxonomique
- Possibilité de masquer les observateurs avec le nouveau paramètre ``ANONYMIZE``
- Possibilité que les liens dans le menu latéral soient des liens externes (en remplacant la clé ``template`` par la clé ``url`` au niveau du paramètre ``STATIC_PAGES``)

**4. Nouvelles espèces**

- Ajout d'un bloc "Nouvelles espèces observées" sur la page d'accueil, permettant d'afficher les dernières espèces découvertes (première observation d'une espèce) sur le territoire (#85 par @MathildeLeclerc)

**5. Autres**

- Possibilité d'afficher l'echelle sur la carte avec le paramètre ``ENABLE_SCALE`` (#293 par @mvergez)
- Possibilité d'ajouter un masque sur la carte en dehors du territoire avec le paramètre ``MASK_STYLE`` (#89 par @mvergez)
- Ajout de pictos manquants (#272 par @jpm-cbna)

**6. Développement**

- Support de Debian 11
- Installation découpée (#332 et #349 par @corentinlange)
- Mise en place de npm pour installer les dépendances (#310 par @corentinlange)
- Mise en place de la structure de tests Backend (avec Pytest) et Frontend (avec Jest) (#297 et #316)
- Remplacement de ``supervisor`` par ``systemd``
- Ajout d'un paramètre de définition du timeout de gunicorn (#271 par @jpm-cbna)
- Mise à jour des dépendances
- Réorganisation du code et packaging
- Ajout d'une page de recherche avancée, permettant d'afficher les observations par maille de 3 espèces en même temps, à tester et finaliser (#313 par @lpofredc)
- Ajout de la possibilité de proposer d'autres types de zonages que les communes, à tester, génériciser et finaliser (#209 par @lpofredc)

🐛 **Corrections**

- Retrait des ``-n`` dans le fichier d'installation (#306 par @corentinlange)
- Correction de l'API ``searchCommune`` en fermant les sessions DB (#277 par @jpm-cbna)

⚠️ **Notes de version**

Si vous mettez à jour GeoNature-atlas :

- Stopper le service ``atlas`` de supervisor (``sudo supervisorctl stop atlas``). Supprimez également le fichier de configuration supervisor de l'atlas (``sudo supervisorctl remove atlas && sudo rm /etc/supervisor/conf.d/atlas-service.conf && sudo supervisorctl reread``)
- Ajouter la variable ``SECRET_KEY`` au fichier ``config.py`` (utilisée pour chiffrer la session), et remplissez-la avec une chaine de texte aléatoire.
- Relancer l'installation complète de la BDD car de nombreux éléments ont évolué, en lancant le script ``install_db.sh``, après avoir passé le paramètre ``drop_apps_db`` à ``true`` dans le fichier ``settings.ini``. Cela va complètement supprimer et recréer votre BDD de GeoNature-atlas. Si vous aviez modifié la vue ``synthese.syntheseff`` ou des vues matérialisées, vous devrez reporter ces modifications après la réinstallation de la BDD de GeoNature-atlas.

  Si votre GeoNature-atlas est connecté à une BDD GeoNature distante, vous devez au préalable étendre les droits de lecture de l'utilisateur PostgreSQL utilisé pour lire les données au niveau de cette BDD GeoNature source (https://github.com/PnX-SI/GeoNature-atlas/blob/master/atlas/configuration/settings.ini.sample#L65) :

  ::

      GRANT USAGE ON SCHEMA utilisateurs, gn_meta TO geonatatlas;
      GRANT SELECT ON ALL TABLES IN SCHEMA utilisateurs, gn_meta TO geonatatlas;

- Suivez la procédure classique de mise à jour de l'application.
- Le nom du service systemd est désormais ``geonature-atlas``
- Les logs sont désormais dans ``/var/log/geonature-atlas.log``. Vous pouvez supprimer le répertoire ``log`` à la racine de l'atlas qui est obsolète.

1.4.2 (2020-11-25)
------------------

**🐛 Corrections**

* Désactivation de la route des observations ponctuelles quand l'atlas est paramétre en mode mailles (#237 par @lpofredc)
* Correction de l'affichage des rangs taxonomiques sur les fiches espèces
* Ajout d'index sur les vues matérialisées ``atlas.t_layer_territoire`` et ``atlas.vm_mailles_territoire`` pour pouvoir les rafraichir en parallèle (#254 et #260)
* Correction des observations dupliquées dans les fiches communes (#225 par @jpm-cbna)
* Correction des liens vers les fiches espèce depuis la carte de la page d'accueil en mode mailles (#221 par @jpm-cbna et @lpofredc)
* Correction du spinner pour la recherche par commune (#227 par @jpm-cbna)
* Corrections CSS supprimant un scroll horizontal global (par @jpm-cbna) et un problème de positionnement sur la page de présentation
* Mise à jour de la dépendance Python ``SQLAlchemy`` en version 1.3.19
* Clarification de la documentation et du fichier d'exemple de ``settings.ini``

**⚠️ Notes de version**

* Si vous mettez à jour l'application, exécutez le script SQL de mise à jour de la BDD : https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/update_1.4.1to1.4.2.sql
* Si vous disposiez d'un GeoNature de version inférieure à 2.5 et que vous passez à cette version, adaptez la table étrangère : ``ALTER FOREIGN TABLE synthese.synthese DROP id_nomenclature_obs_meth;``
* Suivez la procédure classique de mise à jour : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/installation.rst#mise-%C3%A0-jour-de-lapplication

1.4.1 (2019-10-09)
------------------

**🐛 Corrections**

* Correction de syntaxe dans le fichier exemple de la configuration ``config.py.example`` (#206 et #208)
* Correction du responsive sur la page d'accueil
* Correction du slider d'année sur les fiches espèce en mode maille
* Correction d'un import python incorrect (#205)
* Corrections mineures et mise en forme de la documentation
* Requete ``get_taxon`` : utilisation ``get_or_none`` au lieu de prendre l'index 0 de la liste (#207)
* Correction de la serialisation de la route des observations ponctuelles (doit contenir la clé ``year`` pour que le slider fonctionne)

**⚠️ Notes de version**

* Si vous effectuez une montée de version, la correction du responsive nécessite une correction sur le fichier du customisation ``introduction.html``. Supprimer simplement la première balise ``<div class="col-sm-12">`` et sa balise fermante correspondante (à la dernière ligne du fichier).
* Suivez la procédure classique de mise à jour : https://github.com/PnX-SI/GeoNature-atlas/blob/master/docs/installation.rst#mise-%C3%A0-jour-de-lapplication

1.4.0 (2019-10-01)
------------------

**🚀 Nouveautés**

* Compatible avec GeoNature version 2 et connexion possible au réferentiel géographique (#162)
* Fiches espèce : les mailles ne sont plus dupliquées pour améliorer les performances (#53)
* Passage à Python 3 (par @aroche)
* Prise en compte de la dégradation des données (centroïde de la géométrie dégradée) de GeoNature, basé sur les niveaux de diffusion du SINP (voir http://standards-sinp.mnhn.fr/nomenclature/5-niveaux-de-precision-de-diffusion-souhaites-niveauprecision-23-06-2016/)
* Amélioration du module de recherche de taxons (AJAX + trigrammes) (par @aroche)
* Amélioration du module de recherche de commune (AJAX) (par @aroche)
* Chargement "paresseux" des images dans les listes de taxons et la page d'accueil (par @aroche)
* Mise en place de paramètres par défaut, surcouchables si besoin. Vérification des paramètres de configuration grâce à Marshmallow et passage de paramètres par défaut si paramètres absents
* Simplification du passage de la configuration aux routes
* Ajout de la description, de la licence et de la source sur les médias (par @sig-pnrnm)
* Formatage des grands nombres (par @jbdesbas)
* Ordonnancement des noms de communes par longueur (#193) (par @jbdesbas)
* Standardisation GeoJson des API
* Ajout de fonctions SQL pour rafraichir uniquement les vues matérialisées des données dans l'ordre (``atlas.refresh_materialized_view_data()``) ou uniquement les données géographiques plus stables (``atlas.refresh_materialized_view_ref_geo()``)
* Possibilité de masquer le slider de la carte des fiches espèces (``ENABLE_SLIDER``)
* Possibilité de limiter l'étendue de la carte (paramètre ``MAX_BOUNDS``) (par @jbdesbas)
* Ajout du paramètre ``REDIMENSIONNEMENT_IMAGE`` qui active ou non le redimmensionnement à la volée par TaxHub
* Ajout du paramètre ``DISPLAY_PATRIMONIALITE`` qui contrôle l'affichage du logo "patrimonial" sur les fiches espèce et les listes
* Rafraichissement du graphisme
* Facilitation de la customisation grâce à des variables CSS
* Compléments divers de la documentation (``/docs/``)

**🐛 Corrections**

* Renommage du répertoire ``main`` en ``atlas``
* Suppression du paramètre ``COLONNES_RANG_STAT`` (calculé)
* Suppression du paramètre ``IGNAPIKEY`` (le passer directement dans les variables ``MAP.FIRST_MAP`` et ``MAP.SECOND_MAP``)
* Corrections diverses (par @xavyeah39 et @RomainBaghi)

**⚠️ Notes de version**

Si vous souhaitez connecter l'atlas à GeoNature 2, préferez une nouvelle installation de GeoNature-atlas 1.4.0, plutôt qu'une migration.

Dans le cas contraire, suivez les instructions suivantes :

* Ajouter l'extension Trigramme à PostgreSQL :

::

    sudo ls
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

Lancer le script de migration update_1.3.2to1.4.0.sql (https://github.com/PnX-SI/GeoNature-atlas/blob/master/data/update_1.3.2to1.4.0.sql) avec l'utilisateur lecteur de l'application (cf settings.ini : ``user_pg``)

* Des nouvelles variables CSS permettent de customiser les couleurs de l'application. Vous pouvez ajouter les variables ci-dessous au fichier ``static/custom/custom.css`` et les adapter à votre contexte (les variables ``--main-color`` et ``--second-color`` sont les couleurs principalement utilisées : bouton, scrollbar, navbar etc...)

::

    :root {
    --main-color: #82c91e;
    --second-color: #649b18;
  }

Suivez ensuite les instructions suivantes :

* Télécharger puis dézipper la nouvelle version de l'atlas.

::

    cd /home/`whoami`
    wget https://github.com/PnX-SI/GeoNature-atlas/archive/X.Y.Z.zip
    unzip X.Y.Z
    rm X.Y.Z

* Renommer l'ancienne version de l'atlas puis la nouvelle version.

::

    mv /home/`whoami`/atlas/ /home/`whoami`/atlas_old/
    mv GeoNature-atlas-X.Y.Z /home/`whoami`/atlas/

* Copier les fichiers ``settings.ini`` et ``config.py`` depuis l'ancienne version vers la nouvelle pour récupérer vos paramètres de configuration :

::

    cd atlas
    cp ../atlas_old/main/configuration/settings.ini atlas/configuration/settings.ini
    cp ../atlas_old/main/configuration/config.py atlas/configuration/config.py


* Ouvrir le fichier ``settings.ini`` pour y rajouter le nouveau paramètre suivant (laisser la valeur fournie) :

::

    python_executable=/usr/bin/python3

* Le passage à Python 3 nécessite quelques évolutions dans le fichier ``config.py`` : il faut supprimer tous les appels à la fonction ``unicode``). Ouvrez-le, puis supprimer la ligne 20 ``STRUCTURE = unicode(STRUCTURE, 'utf-8')``, la ligne 24 ``NOM_APPLICATION = unicode(NOM_APPLICATION, 'utf-8')`` et les lignes 113-114 ``for i in range(len(RANG_STAT_FR)): RANG_STAT_FR[i]=unicode( RANG_STAT_FR[i], 'utf-8')``

* Dans le fichier ``config.py``, supprimer le paramètre ``IGNAPIKEY`` et intégrer votre clé IGN directement dans les variables ``FIRST_MAP`` et ``SECOND_MAP``.

* Si le redimmensionnement d'image était activé, passer la variable ``REDIMENSIONNEMENT_IMAGE`` à ``True`` dans le fichier de configuration ``config.py``

* Copier le contenu du répertoire ``static/custom/`` depuis l'ancienne version vers la nouvelle pour récupérer toute votre customisation (CSS, templates, images...) :

::

    cp -aR ../atlas_old/static/custom/ ./static

* Relancez l'installation automatique de l'application :

::

    ./install_app.sh

* Relancer l'application

::

    sudo supervisorctl restart atlas

1.3.2 (2018-05-17)
------------------

**Corrections**

* Correction erreur d'import inutilisé dans ``initAtlas.py``

1.3.1 (2018-03-15)
------------------

**Corrections**

* Correction de l'installation autonome (sans GeoNature)
* Correction et documentation si l'atlas est accessible dans un sous-répertoire du domaine
* Correction d'une coquille dans le SQL. Merci @lpofredc

1.3.0 (2018-02-15)
------------------

**Nouveautés**

* Passage de WSGI à Gunicorn pour simplifier et homogénéiser les serveurs Web des différentes applications (TaxHub, GeoNature...)
* Télécharger TAXREF sur geonature.fr et non plus sur le dépôt de TaxHub
* Amélioration du message par défaut sur la HOME pour les dernieres observations
* Optimisation de certaines requêtes
* Prise en compte du HTML dans le champs AUTEUR
* Ajout de picto pour les groupes Hépatiques et Anthocérotes
* Prise en compte des groupes INPN contenant des espaces
* TaxHub 1.3.2 permet de générer à la volée des vignettes des images. Ces vignettes sont désormais utilisables dans GeoNature-atlas pour éviter de charger des grandes images dans les listes de taxons. Pour cela un paramètre ``TAXHUB_URL`` a été ajouté (#129)
* Dans les versions précédentes seule une page statique PRESENTATION était disponible. Seul son contenu était modifiable. Les pages statiques sont désormais paramétrables (template, nom, picto et ordre) et il est possible d'en créer autant qu'on le souhaite en les listant dans le paramètre ``STATIC_PAGES`` (#131)
* Possibilité de customiser l'affichage des points et leur style en fonction des valeurs du champs voulu dans ``atlas.vm_observations``. Pour cela, il faut renseigner le fichier de surcouche javascript ``static/custom/maps-custom.js`` (#133)
* Possibilité de customiser l'affichage et les valeur de la colonne Patrimonialité dans les listes de taxons, à l'aide du paramètre ``PATRIMONIALITE`` dans ``main/configuration/custom.py`` (#134)

**Corrections**

* Suppression d'un double appel à un fichier JS dans le template des fiches espèces (merci @sig-pnrnm)
* Correction d'un bug du slider et de la carte Leaflet dans Chrome (#109)
* Correction des jointures pour prévenir les caractères invisibles (#121, merci @mathieubossaert)
* Correction de l'affichage des singulers et pluriels en ajoutant des conditions (merci @Splendens)
* Amélioration, formatage et simplification de la gestion des paramètres dans le fichier de routes ``main/atlasRoutes.py``
* Important nettoyage du code, factorisation et style

**Notes de version**

* Suivre la procédure standard de mise à jour
* Compléter le fichier de configuration (``main/configuration/config.py``) en ajoutant les nouveaux paramètres ``TAXHUB_URL`` et ``STATIC_PAGES``, en se basant sur le fichier d'exemple ``main/configuration/config.py.sample``.
* Compléter ce même fichier de configuration en adaptant le paramètre ``PATRIMONIALITE`` au nouveau fonctionnement. Pour un fonctionnement par défaut, vous pouvez copier le paramétrage par défaut (https://github.com/PnEcrins/GeoNature-atlas/blob/c27f15af3879d6f2664d0e3220dd32c52e5145df/main/configuration/config.py.sample#L165-L177)
* Pour que les modifications du fichier de configuration soient prises en compte, il faut désormais lancer ``sudo supervisorctl reload``.
* Exécutez le script de mise à jour de la BDD ``data/update_1.2.6to1.3.0.sql`` après l'avoir analysé et lu ses commentaires
* Passage de WSGI à Gunicorn....

Compléter le fichier ``main/configuration/settings.ini`` avec les parties ``Gunicorn settings`` et ``Python settings``, en se basant sur le fichier d'exemple ``main/configuration/settings.ini.sample``

::

  sudo apt-get install -y supervisor
  ./install_app.sh

Activer les modules et redémarrer Apache

::

    sudo a2enmod proxy
    sudo a2enmod proxy_http
    sudo apache2ctl restart

Supprimer le fichier ``atlas.wsgi`` si il est présent à la racine de l'application

Mettre à jour la configuration Apache de votre GeoNature-atlas (``/etc/apache2/sites-available/atlas.conf``) en remplacant son contenu (modifier le port en fonction) :

::

    # Configuration Geonature-atlas
    RewriteEngine  on
    RewriteRule    "atlas$"  "atlas/"  [R]
    <Location /atlas>
        ProxyPass  http://127.0.0.1:8080/
        ProxyPassReverse  http://127.0.0.1:8080/
    </Location>
    #FIN Configuration Geonature-atlas

* Reportez les modifications du template ``static/custom/templates/introduction.html`` en répercutant la nouvelle méthode d'obtention des templates des pages statiques : https://github.com/PnEcrins/GeoNature-atlas/blob/6d8781204ac291f11305cf462fb0c9e247f3ba59/static/custom/templates/introduction.html.sample#L15

* Modifier votre template ``static/custom/templates/presentation.html`` en répercutant la modification du nom du fichier CSS des pages statiques : https://github.com/PnEcrins/GeoNature-atlas/blob/6d8781204ac291f11305cf462fb0c9e247f3ba59/static/custom/templates/presentation.html.sample#L20

1.2.6 (2017-06-30)
------------------

**Nouveautés**

* Ajout des paramètres ``BORDERS_COLOR`` et ``BORDERS_WEIGHT`` pour modifier la couleur et l'épaisseur des limites du territoire.
* Passer la fonction PostgreSQL ``RefreshAllMaterializedViews`` en mode concurrent par défaut https://www.postgresql.org/docs/9.4/static/sql-refreshmaterializedview.html

**Corrections**

* Utiliser aussi ces paramètres pour la légende des cartes
* Correction de la légende de la carte de la Home en mode point (qui affichait la légende des Mailles)

**Notes de version**

* Ajoutez les paramètres ``BORDERS_COLOR`` et ``BORDERS_WEIGHT`` dans votre fichier ``main/configuration/config.py`` comme indiqué dans le fichier d'exemple (https://github.com/PnEcrins/GeoNature-atlas/blob/master/main/configuration/config.py.sample)
* Si vous utilisez une version supérieure à 9.3, il est conseillé de rafraichir les vues matérialisées de manière concurrente pour ne pas bloquer l'accès à la BDD pendant un rafraichissement. Si ce n'est pas le cas pour votre vue, il est conseillé de la modifier (schéma ``public``) comme proposé désormais : https://github.com/PnEcrins/GeoNature-atlas/blob/master/data/atlas.sql#L406-L423

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
