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

    # echo $__conf_dir__
    source "${__conf_dir__}/settings.ini"
    checkSettings
    exportPostgresPassword


    dropAndRecreateSchemaAtlas
    prepareAltitudesValues
    createAtlasSchemaEntities
    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}


function dropAndRecreateSchemaAtlas() {
    printVerbose "Drop schema atlas..."
    printMsg "Attention cette action necessite de supprimer le schéma atlas..."
    read -p "Etes vous sur de vouloir continuer? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

    executeQuery "DROP SCHEMA IF EXISTS atlas CASCADE";
    executeQuery "CREATE SCHEMA atlas";
}



main "${@}"
