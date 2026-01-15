#!/usr/bin/env bash

#+------------------------------------------------------------------------------------------------+
# Configure script execute options
set -euo pipefail

function main() {

    #+-------------------------------------------------------------------------+
    # Load utils
    current_dir=$(dirname "${BASH_SOURCE[0]}")
    source "${current_dir}/utils/utils_install.bash"
    initScript "${@}"

    printMsg "Attention cette action necessite de supprimer le schéma atlas et toutes les foreign tables..."
    read -p "Etes vous sur de vouloir continuer? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1



    # echo $__conf_dir__
    source "${__conf_dir__}/settings.ini"
    checkSettings
    exportPostgresPassword

    createDatabaseSchemas

    if ${geonature_source}; then
        createFdwTables
    fi
    dropAndRecreateSchemaAtlas
    prepareAltitudesValues
    createAtlasSchemaEntities
    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}


function dropAndRecreateSchemaAtlas() {
    printVerbose "Drop schema atlas..."
    executeQuery "DROP SCHEMA IF EXISTS atlas CASCADE";
    executeQuery "CREATE SCHEMA atlas";
}



main "${@}"
