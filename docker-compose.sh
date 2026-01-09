#!/usr/bin/env bash

#######################################################################
#######################################################################
# Ce script est un wrapper qui permet d'exporter en variable d'env tous 
# les paramètre du fichier `settings.ini`. Il est indispensable pour avoir 
# les identifiants de BDD pour le service postgres
# La script s'utilise comme une commande docker compose normale
# Exemple : 
# ./docker-compose.sh up
# - ./docker-compose.sh run --rm atlas-app install/install_db.sh --docker
#######################################################################
#######################################################################
set -e


INI_FILE="atlas/configuration/settings.ini"

if [ ! -f "$INI_FILE" ]; then
  echo "❌ settings.ini introuvable: $INI_FILE"
  exit 1
fi

# toute variable défini est exportée
set -a
source "$INI_FILE"
set +a

exec docker compose "$@"