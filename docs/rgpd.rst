La RGPD
=======

À quoi sert la RGPD
-------------------

Le règlement général sur la protection des données est utilisé afin de protéger les données à caractère personnel.

Où configurer l'application
---------------------------

Dans le fichier : `atlas/configuration/config.py`

La documentation correspondant à la configuration : https://github.com/empreinte-digitale/orejime

- Définir les applications pour lesquelles il faut bloquer les cookies via la variable **OREJIME_APPS**

::

    OREJIME_APPS = [
        {
            "name": "scripts-gtm",
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

::

    OREJIME_TRANSLATIONS =  {
        "en": {
            "consentModal": {
                "description": "This is an example of how to override an existing translation already used by Orejime",
            },
            "inlineTracker": {
                "description": "Example of an inline tracking script",
            },
            "externalTracker": {
                "description": "Example of an external tracking script",
            },
            "purposes": {
                "analytics": "Analytics",
                "security": "Security"
            },
            "categories": {
                "analytics": {
                    "description": "A long form description of the category."
                }
            }
        },
        }

- Il est possible de catégoriser les applications nécessaires afin de les intégrer dans les choix des utilisateurs.

.. image :: images/choice_rgpd.png


::

    OREJIME_CATEGORIES = [
            {
                "name": "analytics",
                "title": "Analytics",
                "apps": [
                    "scripts-gtm",
                    "second-script"
                ]
            }
        ]

Dans le fichier : `atlas/static/custom/templates/footer.html`

- Dans le fichier, rajouter un **if** pour chacun des scripts à exécuter.

Dans cet exemple, il s'agit d'un script de google analitics (le script `scripts-gtm` définit dans la configuration orejime dans le fichier `config.py`).

::

    {% if configuration.OREJIME_APPS|length > 0 %}
    <!-- Sample script Analytics Google -->
        {% for app in configuration.OREJIME_APPS %}
            {% if app.name == "scripts-gtm" %}
                <script
                        type="opt-in"
                        data-type="application/javascript"
                        data-name="scripts-gtm">
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

                    ga('create', '{{configuration.ID_GOOGLE_ANALYTICS}}', 'auto');
                    ga('send', 'pageview');
                </script>
            {%  endif %}
        {% endfor %}
    {% endif %}
