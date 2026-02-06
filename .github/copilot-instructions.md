# Instructions GitHub Copilot pour GeoNature-atlas

## À quoi sert GitHub Copilot ?

GitHub Copilot est un assistant de programmation IA qui vous aide dans vos tâches de développement sur ce projet. Il peut :

- **Comprendre le code** : Analyser et expliquer le code existant du projet
- **Écrire du code** : Générer du code Python, JavaScript, SQL selon les conventions du projet
- **Déboguer** : Identifier et corriger des bugs dans votre code
- **Documenter** : Créer ou améliorer la documentation
- **Refactoriser** : Améliorer la structure du code tout en préservant sa fonctionnalité
- **Tester** : Créer des tests unitaires et d'intégration avec pytest
- **Répondre aux questions** : Expliquer comment fonctionne le projet, ses dépendances, sa configuration

## Contexte du projet GeoNature-atlas

GeoNature-atlas est un atlas web dynamique de faune et flore développé en Python (Flask) et JavaScript. Il permet de :

- Générer dynamiquement des fiches espèces avec des données calculées automatiquement
- Afficher des cartes de répartition, des graphiques altitudinaux et phénologiques
- Publier en ligne des observations naturalistes de manière dynamique
- Se connecter à différentes sources de données (GeoNature, SERENA, SICEN, etc.)

### Technologies utilisées

- **Backend** : Python 3.x avec Flask, SQLAlchemy 2
- **Frontend** : JavaScript (jQuery), Bootstrap 5, Leaflet
- **Base de données** : PostgreSQL avec PostGIS
- **Tests** : pytest
- **Linting** : Black (Python), ESLint (JavaScript)

## Comment utiliser Copilot sur ce projet ?

### 1. Questions générales

Vous pouvez poser des questions sur le projet :

- "Comment fonctionne le système de fiches espèces ?"
- "Où est définie la configuration de la base de données ?"
- "Comment ajouter une nouvelle carte sur la page d'accueil ?"
- "Quelles sont les dépendances principales du projet ?"

### 2. Développement de fonctionnalités

Demandez à Copilot de vous aider à créer du code :

- "Crée une nouvelle route Flask pour afficher les observations d'un territoire"
- "Ajoute un filtre JavaScript pour trier les espèces par nom"
- "Écris une fonction pour calculer la répartition altitudinale d'un taxon"

### 3. Débogage

Décrivez le problème et Copilot vous aidera :

- "J'ai une erreur SQLAlchemy lors de la création de la vue matérialisée"
- "Ma carte Leaflet ne s'affiche pas correctement"
- "Le filtrage des statuts de conservation ne fonctionne pas"

### 4. Tests

Demandez la création de tests :

- "Crée des tests pytest pour la fonction de calcul de patrimonialité"
- "Écris des tests pour la route API qui retourne les observations"

### 5. Documentation

Améliorez la documentation :

- "Documente cette fonction avec une docstring complète"
- "Crée un guide d'utilisation pour le paramètre COUCHES_SIG"

### 6. Refactoring et qualité du code

Améliorez le code existant :

- "Refactorise cette fonction pour la rendre plus lisible"
- "Vérifie que ce code respecte les conventions PEP 8"
- "Applique les règles ESLint à ce fichier JavaScript"

## Conventions du projet à respecter

Copilot est configuré pour respecter les conventions suivantes :

### Python
- Formatage avec **Black** (100 caractères par ligne)
- Conventions PEP 8
- CamelCase pour les classes
- snake_case pour les fonctions et variables
- Docstrings pour les fonctions

### JavaScript
- Configuration ESLint définie dans `atlas/static/eslint.config.js`
- Utiliser `const` et `let`, éviter `var`
- Préférer les fonctions fléchées pour les callbacks

### Base de données
- Schéma principal : `atlas`
- Vue matérialisée des observations : configurée via `observation_data_source`
- Utilisation de Foreign Data Wrapper (FDW) pour se connecter à GeoNature

### Structure du projet
```
├── atlas/                  # Code source principal
│   ├── atlasapp.py        # Application Flask
│   ├── configuration/     # Configuration
│   ├── modeles/          # Modèles SQLAlchemy
│   ├── static/           # Fichiers statiques (JS, CSS, images)
│   └── templates/        # Templates Jinja2
├── data/                  # Données de référence
├── docs/                  # Documentation
├── install/              # Scripts d'installation
└── tests/                # Tests unitaires
```

## Exemples de commandes utiles

### Linting et formatage
```bash
# Python
black .
black --check .

# JavaScript
npm run lint
npm run format
```

### Tests
```bash
export ATLAS_SETTINGS=/path/to/test_config.py
pytest
```

### Base de données
```bash
cd install
./install_db.sh
```

## Fichiers de configuration importants

- `config.py` : Configuration principale de l'application
- `settings.ini` : Configuration de l'installation (base de données, etc.)
- `pyproject.toml` : Configuration Python (dépendances, Black)
- `package.json` : Dépendances JavaScript
- `atlas/static/eslint.config.js` : Configuration ESLint

## Limitations et bonnes pratiques

1. **Vérifiez toujours le code généré** : Copilot est un assistant, pas un remplacement du développeur
2. **Testez vos modifications** : Lancez les tests et vérifiez manuellement les changements
3. **Respectez les conventions** : Assurez-vous que le code généré respecte les standards du projet
4. **Consultez la documentation** : La documentation complète est disponible sur https://pnx-si.github.io/GeoNature-atlas/
5. **Faites des commits atomiques** : Un commit par fonctionnalité/correction

## Ressources

- Documentation officielle : https://pnx-si.github.io/GeoNature-atlas/
- Dépôt GitHub : https://github.com/PnX-SI/GeoNature-atlas
- Guide de contribution : `docs/CONTRIBUTING.md`
- FAQ : `docs/FAQ.md`
- Changelog : `docs/changelog.rst`

## Support

Pour toute question ou problème :
- Créez une [issue](https://github.com/PnX-SI/GeoNature-atlas/issues)
- Consultez la FAQ dans `docs/FAQ.md`
- Consultez les discussions existantes sur GitHub

---

**Note** : Ce fichier d'instructions aide GitHub Copilot à mieux comprendre le contexte du projet et à fournir des suggestions plus pertinentes. Il n'est pas nécessaire de le modifier sauf si la structure ou les conventions du projet changent.
