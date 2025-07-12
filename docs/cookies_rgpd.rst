Gestion des cookies et RGPD
===========================

Cette section explique comment ajouter des outils de collecte de cookies (Google Analytics par exemple) tout en respectant le RGPD. GeoNature-atlas utilise pour cela une librairie permettant de recueillir le consentement des utilisateurs : Orejime.

À quoi sert le RGPD
-------------------

Le règlement général sur la protection des données (RGPD) est utilisé afin de protéger les données à caractère personnel.

Par exemple, Google Analytics permet de suivre le trafic de consultation d'un site internet comme GeoNature-atlas, mais stocke des informations sur les utilisateurs, pour lesquelles le RGPD impose un consentement de chaque utilisateur. L'outil de gestion des cookies permet de gérer ce consentement. Attention, tous les utilisateurs qui ne valideront pas le consentement ne seront pas comptabilisés et les chiffres de fréquentation seront donc plus faibles que la réalité. Pour suivre la fréquentation d'un portail GeoNature-atlas, il est donc conseillé de plutôt utiliser des solutions compatibles RGPD sans collecte de cookies et donc sans nécessiter de demande consentement comme Matomo (https://matomo.org/get/comment-se-passer-de-gestionnaire-de-consentement-2e/).

Où configurer l'application
---------------------------

Veuillez d'abord à bien récupérer le contenu du fichier ``footer.html.sample`` dans votre fichier ``footer.html`` si vous aviez GeoNature-atlas avant la version 1.7.0.

Dans le fichier ``atlas/configuration/config.py`` :

- Passer la variable à ``AFFICHAGE_RGPD = True``
- Définir les applications pour lesquelles il faut demander l'autorisation de la collecte de cookies via la variable **OREJIME_APPS**

En complément, se référer à la documentation officielle de l'outil Orejime : https://github.com/empreinte-digitale/orejime

::

    OREJIME_APPS = [
        {
            "name": "script-google", # ce nom devra être réutilisé dans la balise script (attribut `data-name`) du fichier `footer.html` où le script d'analyse des cookies sera integré
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

- Il est possible de surcharger les traductions grâce à la variable ``OREJIME_TRANSLATIONS``.

Voir toutes les possibilités de traduction : https://github.com/empreinte-digitale/orejime.

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

A la fin du fichier : ``atlas/static/custom/templates/footer.html``, copiez collez cet exemple en l'adaptant à votre contexte et à votre configuration.

La variable ``AFFICHAGE_FOOTER`` doit être mise à ``True`` si on souhaite ajouter des traceurs de cookies.

Dans cet exemple, il s'agit d'un script de Google Analytics :

L'attribut ``data-name`` de la balise script doit correspondre à l'attribut ``name`` correspondant à l'application OREJIME renseigné dans la variable de configuration ``OREJIME_APPS``. Dans la configuration d'exemple, la première "l'app google" a pour attribut ``name`` : ``scripts-google``, il faut donc mettre ``scripts-google`` dans l'attribut ``data-name`` de la balise ``script``. C'est cet attribut qui permet à Orejime de savoir quel cookie il va pouvoir accepter ou bloquer en fonction de la réponse de l'utilisateur.

Si vous souhaitez rajouter un deuxième traceur, faire un deuxième balise script séparée en respectant la même logique.

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
