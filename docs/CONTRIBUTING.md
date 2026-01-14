# Contribuer

Merci de votre intérêt pour contribuer à GeoNature-atlas ! Ce document vous guidera à travers les bonnes pratiques et les conventions de développement du projet.

## Table des matières

- [Qualité du code](#code-quality)
- [Processus de contribution](#contribution-process)
- [Tests automatisés](#test)
- [Documentation](#documentation)
- [Questions et support](#support)

## Prérequis

Avant de commencer à contribuer, assurez-vous d'avoir :

- Python 3.x installé
- Node.js et npm installés
- Git installé et configuré
- Une bonne compréhension de Flask (backend) et JavaScript (frontend)
- Installer l'application !
- Installer les dépendances python de développement : `pip install ".[dev]` (depuis la racine du répertoire)
- Installer les dépendances javascript de développement `npm install --only=dev`

Le [fichier](./src/installation.rst) détail l'installation d'un environnement de développement de GeoNature-Atlas

(code-quality)=

## Qualité et convention du code

Le projet utilise des outils de formatage et de linting pour maintenir une qualité de code cohérente.

### Python

Le code Python doit être formaté avec **Black**. La configuration de Black se trouve dans le fichier `pyproject.toml`.

- Suivez les conventions PEP 8, appliquées automatiquement par Black
- Utilisez des noms de variables explicites en anglais
- Commentez le code complexe
- Documentez les fonctions avec des docstrings

#### Formater le code Python

Pour formater automatiquement votre code Python :

```bash
black .
```

#### Vérifier le formatage sans modifier les fichiers

```bash
black --check .
```

#### Configuration Black

La configuration Black utilisée dans le projet (définie dans `pyproject.toml`) :

- Longueur de ligne : 100 caractères

Ces deux règles ne sont pas dans black mais sont à respecter :

- CamelCase pour les noms de classe
- snake_case pour les noms de fonction et de variable

### JavaScript

Le code JavaScript doit respecter les règles définies par **ESLint** (voir `atlas/static/eslint.config.js`)

- Respectez les règles ESLint configurées
- Utilisez `const` et `let`, évitez `var`
- Préférez les fonctions fléchées pour les callbacks
- Commentez le code complexe

#### Lancer le linter JavaScript

Pour vérifier votre code JavaScript :

```bash
npm run lint
```

#### Corriger automatiquement les erreurs ESLint

```bash
npm run format
```

(contribution-process)=
## Processus de contribution

### 1. Créer une issue

Avant de commencer à travailler sur une nouvelle fonctionnalité ou un correctif, créez une issue pour en discuter avec les mainteneurs du projet.

### 2. Créer une branche

Créez une branche dédiée à partir de `develop` :

```bash
git checkout develop
git pull origin develop
git checkout -b feature/ma-nouvelle-fonctionnalite
# ou
git checkout -b fix/correction-bug
```

- Ne mergez pas la branche `develop` dans votre branche de feature, utilisez la commande `rebase`
- Ne faites pas de commit de lint, privilegiez un `git commit --amend` pour ajouter le lint au commit comprenant les modification du code.
- Squachez vos pull requests lorsqu'elle sont prêtes à être relues
- Assurez vous que les tests passent et que le codecov ne baisse pas

Conventions de nommage des branches :

- `feature/` pour les nouvelles fonctionnalités
- `fix/` pour les corrections de bugs
- `docs/` pour la documentation
- `refactor/` pour les refactorisations



### 3. Développer et commiter

Effectuez vos modifications en respectant les conventions de code. Faites des commits atomiques avec des messages clairs et descriptifs. Pensez à réferencer l'issue dans votre commit.
Ecrivez des tests sur les fonctionnalités que vous développez.

Types de commit courants :

- `feat:` nouvelle fonctionnalité
- `fix:` correction de bug
- `docs:` documentation
- `style:` formatage, points-virgules manquants, etc.
- `refactor:` refactorisation du code
- `test:` ajout ou modification de tests
- `chore:` maintenance, dépendances, configuration

### 4. Pousser votre branche

```bash
git push <mon_remote> feature/ma-nouvelle-fonctionnalite
```

### 5. Créer une Pull Request

1. Allez sur GitHub et créez une Pull Request de votre branche vers `develop`
2. Remplissez le template de PR avec :
   - Description des changements
   - Référence à l'issue concernée
   - Screenshots si applicable
3. Assignez des reviewers si nécessaire

### 6. Review et merge

- Les mainteneurs examineront votre PR
- Répondez aux commentaires et effectuez les modifications demandées
- Une fois approuvée, votre PR sera mergée dans `develop`

(test)=
## Tests automatisés

Les tests sont écrit avec la librairie pytest.
Avant de lancer les tests, assurez vous d'avoir créer une base de données pour les tests.

    create database <geonatureatlas_test> with owner <geonatadmin>
    \d <ma_base>
    CREATE EXTENSION IF NOT EXISTS postgis;

Exporter la variable suivante : 

    export ATLAS_SETTINGS=/home/theo/workspace/GeoNature-atlas/atlas/tests/test_config.py

Cela définit le fichier de configuration de l'application avec celui qui est fourni pour les tests. Vous pouvez tout à fait utilisez un autre fichier de configuration

⚠️⚠️ Chaque run de test va supprimer le contenu de la base et la recréer !

Lancer les tests :

    pytest

(documentation)=
## Documentation

- Mettez à jour la documentation si vos changements affectent l'utilisation de l'application
- Les fichiers de documentation se trouvent dans le dossier `docs/`
- Vous pouvez ajouter votre documentation aux formats:
  - `reStructuredText` syntax. See the [reStructuredText documentation](https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html>)
  - `Markdown` syntax. See the [myst-parser documentation](https://myst-parser.readthedocs.io/en/latest/index.html)
- Vous pouvez vérifier la bonne mise en forme de la documentation avec les commandes suivantes:

```bash
cd docs
make livehtml
```

(support)=
## Questions et support

- Pour signaler un bug, créez une [issue](https://github.com/PnX-SI/GeoNature-atlas/issues)
- Pour contacter l'équipe : voir le fichier README


Merci de contribuer à GeoNature-atlas ! 🦋🌿
