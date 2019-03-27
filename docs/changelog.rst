=========
CHANGELOG
=========

1.3.2 (2018-05-17)
------------------

** Nouveautés **

* Passage à python3
* Amélioration du module de recherche de taxons (AJAX + trigrams)
* Amélioration du module de recherche de commune (AJAX)
* Vérification des paramètres de configuration grâce à Marshmallow et passage de paramètres par défaut si paramètres absents
* Simplification du passage de la configuration aux routes
* Ajout de la description, de la licence et de la source sur les médias

**Corrections**

* Renommage du répertoire 'main' en 'atlas'
* Suppression du paramètre COLONNES_RANG_STAT (calculé)
* Suppression du paramètre IGNAPIKEY (le passer directement dans les variables ``MAP.FIRST_MAP`` et ``MAP.SECOND_MAP``)
* Correction erreur d'import inutilisé dans ``initAtlas.py``
* Ajout du paramètre ``REDIMENSIONNEMENT_IMAGE`` qui active ou non le redimmentionnement par TaxHub



**Note de version**

* Replacer la clé IGN dans les variables FIRST_MAP et SECOND_MAP de la manière suivante:

::

    MAP = {
        'LAT_LONG': [44.7952, 6.2287],
        'FIRST_MAP': {
                'url' : 'http://gpp3-wxs.ign.fr/MA_CLE_IGN/wmts?LAYER=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}',
                'attribution' : '&copy; <a href="http://www.ign.fr/">IGN</a>',
                'tileName' : 'IGN'
        },
        'SECOND_MAP' : {'url' :'https://gpp3-wxs.ign.fr/MA_CLE_IGN/geoportail/wmts?LAYER=ORTHOIMAGERY.ORTHOPHOTOS&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}',
                'attribution' : '&copy; <a href="http://www.ign.fr/">IGN</a>',
                'tileName' : 'Ortho IGN'
        },

* Si le redimmentionnement d'image était activé, passer la variable ``REDIMENSIONNEMENT_IMAGE`` à ``True`` dans le fichier de configuration


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
