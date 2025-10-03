#!/usr/bin/env bash

# Script for container Docker Atlas entrypoint
set -eof pipefail

echo "Starting Atlas container..."
if [[ "${ATLAS_INSTALL_SCHEMA}" == "true" ]]; then
    echo "=> Install Atlas app and DB schema..."
    ./install_db.sh --docker --verbose 2>&1
    ./install_app.sh --docker --verbose 2>&1
else
    echo "=> Skip Atlas app and DB schema installation."
fi

# Run Atlas app with Gunicorn
echo "Running Atlas with Gunicorn..."
gunicorn "atlas.wsgi:create_app()" \
    --name="geonature-atlas" \
    --bind="0.0.0.0:8080" \
    --access-logfile=- \
    --error-logfile=- \
    --reload \
    --reload-extra-file="atlas/configuration/config.py" # pour relancer l'application en cas de modification du fichier de configuration
