Gestion des cookies et RGPD
===========================

Cette section explique comment ajouter des outils de collectes de cookies (matomo, Google analytics par ex) tout en respetant le RGPG. GeoNature-Atlas utilise pour cela une librairie permettant de receuillir le consentement de l'utilisateur: Orejime.

À quoi sert le RGPD
-------------------

Le règlement général sur la protection des données est utilisé afin de protéger les données à caractère personnel.

Où configurer l'application
---------------------------

Veuillez d'abord à bien récupérer le contenu du fichier `footer.html.sample` dans votre fichier `footer.html` si vous aviez GeoNature-Atlas avant la version 2.7.0.

Dans le fichier  `atlas/configuration/config.py` :

- Passer la variable à `AFFICHAGE_RGPD = True`
- Définir les applications pour lesquelles il faut demander l'autorisation de la collecte de cookies via la variable **OREJIME_APPS**

En complément, se référer à la documentation officielle de l'outil orejim: https://github.com/empreinte-digitale/orejime

::

    OREJIME_APPS = [
        {
            "name": "script-google", # ce nom devra être réutilisé dans la balise script (attribut `data-name`) du fichier `footer.html` ou le script d'analyse des cookies sera integré
            "title": "Google Analytics",
            "cookies": [
                "_ga",
                "_gat",
                "_gid",
                "__utma",
                "__utmb",
                "__utmc",
                "__utmt",
                "__utmz",
            ],
            "purposes": ["analytics"],
            "required": False,
            "optOut": False,
            "default": True,
            "onlyOnce": True,
        },
        {
            "name": "second-script",
            "title": "Deuxième script",
            "cookies": [
                "_ga",
                "_gat",
                "_gid",
                "__utma",
                "__utmb",
                "__utmc",
                "__utmt",
                "__utmz",
            ],
            "purposes": ["analytics"],
            "required": False,
            "optOut": False,
            "default": True,
            "onlyOnce": True,
        }
    ]

- Il est possible de surcharger les traductions grâce à la variable : **OREJIME_TRANSLATIONS**
Voir toutes les possibilité de traduction : https://github.com/empreinte-digitale/orejime
::

    OREJIME_TRANSLATIONS =  {
        "fr": {
            "consentModal": {
                "description": "",
            },
            "purposes": {
                "analytics": "Analyse",
                "security": "Sécurité"
            }
        },
        "en": {
            "consentModal": {
                "description": "This is an example of how to override an existing translation already used by Orejime",
            },
            "purposes": {
                "analytics": "Analytics",
                "security": "Security"
            },

        }
    }

- Il est possible de catégoriser les applications nécessaires afin de les intégrer dans les choix des utilisateurs.

.. image :: images/choice_rgpd.png

::

    OREJIME_CATEGORIES = [
            {
                "name": "analytics",
                "title": "Analytics",
                "apps": [
                    "script-google",
                ]
            },
            {
                "name": "security",
                "title": "Secutiry",
                "apps": [
                    "second-script",
                ]
            }
        ]

A la fin du fichier : `atlas/static/custom/templates/footer.html`, copiez collez cette exemple en l'adaptant à votre contexte et à votre configuration.
La variable `AFFICHAGE_FOOTER` doit êtes mise à `True` si on souhaite ajouter des traceurs de cookies.

Dans cet exemple, il s'agit d'un script de google analytics : 
L'attribut `data-name` de la balise script doit correspondre a l'attribut `name` correspondant à l'application ORIJIME renseigné dans la variable de configuration `OREJIME_APPS`. Dans la configuration d'exemple, la première "l'app google" a pour attribut `name` : `scripts-google`, il faut donc mettre `scripts-google` dans l'attribut `data-name` de la balise script. C'est cet attribut qui permet à Orijeme de savoir quel cookies il va pouvoir accepter ou bloquer en fonction de la réponse de l'utilisateur.
Si vous souhaitez rajouter un deuxième traceur (matomo par exemple), faire un deuxième balise script séparée en respectant la même logique.

::

    <!-- Sample script Analytics Google -->
        <script
                type="opt-in"
                data-type="application/javascript"
                data-name="scripts-google">
            (function (i, s, o, g, r, a, m) {
                i['GoogleAnalyticsObject'] = r;
                i[r] = i[r] || function () {
                    (i[r].q = i[r].q || []).push(arguments)
                }, i[r].l = 1 * new Date();
                a = s.createElement(o),
                    m = s.getElementsByTagName(o)[0];
                a.async = 1;
                a.src = g;
                m.parentNode.insertBefore(a, m)
            })(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');

            ga('create', '<VOTRE_ID_GOOGLE_A_REMPLACER>', 'auto');
            ga('send', 'pageview');
        </script>
