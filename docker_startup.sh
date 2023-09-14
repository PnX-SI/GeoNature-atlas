#!/bin/bash

# script pour l'entry point du docker atlas

set -eof pipefail
export PGPASSWORD=${POSTGRES_PASSWORD}

# si la variable ATLAS_RESET_SCHEMA est à true
# -> suppression en base de données des schema atlas & synthese
#
if [ "$ATLAS_RESET_SCHEMA" = true ];then
    psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -t -c "DROP SCHEMA IF EXISTS atlas CASCADE"
    psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -t -c "DROP SCHEMA IF EXISTS synthese CASCADE"
fi


# test si le schema atlas existe
schema_atlas_exists=$(psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -t -c "SELECT exists(select schema_name FROM information_schema.schemata WHERE schema_name = 'atlas');" | sed 's/ //g')

# si le schema atlas n'existe pas
if [ ! "$schema_atlas_exists" = "t" ]; then
    echo "Schema atlas inexistant ($schema_atlas_exists)"

    # si la variable ATLAS_INSTALL_SCHEMA est à true (ou ATLAS_RESET_SCHEMA)
    # on procède à l'installation des schema atlas et synthese
    if [ "$ATLAS_INSTALL_SCHEMA" = true ] || [ "$ATLAS_RESET_SCHEMA" = true ] ;then
        echo Installation du schema de l''atlas
        ./docker_install_atlas_schema.sh

    # sinon on  affiche un message avec les indication pour initier la base atlas
    else
        echo Pour installer la db avec cette commande veuillez definir la variable d''environnement ATLAS_INSTALL_SCHEMA=true
        exit 1
    fi
else
    echo Schema atlas déjà installé
fi


# dossier custom

# dossiers
for custom_dir in "images" "templates"; do
    if [ ! -d ${ATLAS_STATIC_FOLDER}/custom/${custom_dir}/ ]; then
        mkdir -p ${ATLAS_STATIC_FOLDER}/custom/${custom_dir}/
    fi
done

# fichiers (avec find ?)
for custom_file in "templates/footer.html" \
    "templates/footer.html" \
    "templates/introduction.html" \
    "templates/presentation.html" \
    "templates/credits.html" \
    "templates/mentions-legales.html" \
    "templates/bandeaulogoshome.html" \
    "templates/robots.txt" \
    "custom.css" \
    "glossaire.json" \
    "maps-custom.js" ; do

    if [ ! -f ${ATLAS_STATIC_FOLDER}/custom/${custom_file} ]; then
        cp ${ATLAS_STATIC_FOLDER}/../custom_save/${custom_file}.sample ${ATLAS_STATIC_FOLDER}/custom/${custom_file}
    fi

done

for custom_file in "favicon.ico" \
    "accueil-intro.jpg" \
    "logo-structure.png" \
    "logo_patrimonial.png" ; do

    if [ ! -f ${ATLAS_STATIC_FOLDER}/custom/images/${custom_file} ]; then
        cp ${ATLAS_STATIC_FOLDER}/images/sample.${custom_file} ${ATLAS_STATIC_FOLDER}/custom/images/${custom_file}
    fi
done


# lancement l'application avec gunicorn
echo Lancement de l''application atlas
gunicorn "atlas.wsgi:create_app()" \
    --name=geonature-atlas \
    --bind=0.0.0.0:8080 \
    --access-logfile=- \
    --error-logfile=- \
    --reload \
    --reload-extra-file=config/config.py # pour relancer l'application en cas de modification du fichier de configuration
