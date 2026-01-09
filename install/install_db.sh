#!/usr/bin/env bash

#+------------------------------------------------------------------------------------------------+
# Configure script execute options
set -euo pipefail

# +-----------------------------------------------------------------------------------------------+
# Main script

# DESC: Usage help
# ARGS: None
# OUTS: None
function printScriptUsage() {
    cat << EOF
Usage: ./$(basename $BASH_SOURCE)[options]
     -h | --help: display this help
     -v | --verbose: display more infos
     -x | --debug: display debug script infos
     -d | --docker: run script in a docker container
EOF
    exit 0
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parseScriptOptions() {
    # Transform long options to short ones
    for arg in "${@}"; do
        shift
        case "${arg}" in
            "--help") set -- "${@}" "-h" ;;
            "--verbose") set -- "${@}" "-v" ;;
            "--debug") set -- "${@}" "-x" ;;
            "--docker") set -- "${@}" "-d" ;;
            "--"*) exitScript "ERROR: parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "hvxd" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") readonly debug=true; set -x ;;
            "d") readonly docker=true ;;
            *) exitScript "ERROR: parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
    #+-------------------------------------------------------------------------+
    # Load utils
    current_dir=$(dirname "${BASH_SOURCE[0]}")
    source "${current_dir}/utils/utils_install.bash"

    #+-------------------------------------------------------------------------+
    # Init script
    initScript "${@}"
    parseScriptOptions "${@}"
    if [[ "${docker:-false}" == false ]]; then
        redirectOutput "${__log_dir__}/install_db.log"
    fi

    #+-------------------------------------------------------------------------+
    # Start install database
    printInfo "${__script_name__} script started at: ${__fmt_time_start__}"


    runDBInstall

    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}

# +-----------------------------------------------------------------------------------------------+
# Functions

function runDBInstall() {
    printVerbose "Running default install..."
    source "${__conf_dir__}/settings.ini"
    checkSettings

    if [[ "${docker:-false}" == false ]]; then
        checkNoUserRoot
        checkSuperuser
        if ! checkDatabaseExists "${db_name}"; then
            createDatabase
        fi
    fi

    exportPostgresPassword

    # Test if Atlas schema exists
    local schema_atlas_exists=$(hasAtlasSchema)

    # If Atlas schema already exists
    if [[ "${schema_atlas_exists}" = "t" ]]; then
        printVerbose "Atlas schema already exists (${schema_atlas_exists})"

        if [[ "${ATLAS_DROP_SCHEMA}" = false ]]; then
            printVerbose "The schema atlas exists and the config file tell to not drop it...Nothing to do."
            printVerbose "To reinstall Atlas at startup set ATLAS_DROP_SCHEMA to 'true'."
            exit 0
        else
            dropAtlasSchema
        fi
    fi

    printVerbose "Installing atlas db..."
    createDatabaseExtensions
    if ${geonature_source}; then
        createForeignDataWrapper
        createFdwTables
    fi
    createDatabaseSchemas
    prepareAltitudesValues
    createAtlasSchemaEntities
    printVerbose "${Gre}The database was successfully installed${RCol} !"

}

# function runDockerInstall() {
#     printVerbose "Running Docker install..."
#     source "${__conf_dir__}/settings.ini"
#     # checkDockerVariables
#     # convertDockerVariables
#     exportPostgresPassword

#     # Test if Atlas schema exists
#     local schema_atlas_exists=$(hasAtlasSchema)

#     # If Atlas schema already exists
#     if [[ "${schema_atlas_exists}" = "t" ]]; then
#         printVerbose "Atlas schema already exists (${schema_atlas_exists})"

#         if [[ "${ATLAS_DROP_SCHEMA}" = false ]]; then
#             printVerbose "The schema atlas exists and the config file tell to not drop it...Nothing to do."
#             printVerbose "To reinstall Atlas at startup set ATLAS_DROP_SCHEMA to 'true'."
#             exit 0
#         else
#             dropAtlasSchema
#         fi
#     fi

#     printVerbose "Installing atlas db..."
#     createDatabaseExtensions
#     if ${geonature_source}; then
#         createForeignDataWrapper
#         createFdwTables
#     fi
#     createDatabaseSchemas
#     prepareAltitudesValues
#     createAtlasSchemaEntities
#     printVerbose "${Gre}The database was successfully installed${RCol} !"

# }


function hasAtlasSchema() {
    local query="SELECT exists(SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'atlas');"
    local schema_atlas_exists=$(
        psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" \
            -t -c "${query}" | \
        sed 's/ //g'
    )

    echo -e "${schema_atlas_exists}"
}

function dropAtlasSchema() {
    printMsg "Dropping Atlas schema in cascade..."

    psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" \
        -c "DROP SCHEMA IF EXISTS atlas CASCADE;"
}


function checkDatabaseExists() {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf as appropriate.
    if [[ -z $1 ]]; then
        # Argument is null
        return 0
    else
        # Grep db name in the list of database
        sudo -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}


# FR: Sinon je créé la BDD
# EN: Else I create the DB
function createDatabase() {
    printMsg "Creating users..."
    set +e
    sudo -u postgres psql -c "CREATE USER ${owner_atlas} WITH PASSWORD '${owner_atlas_pass}' ;"
    sudo -u postgres psql -c "CREATE USER ${user_pg} WITH PASSWORD '${user_pg_pass}' ;"
    set -e

    printMsg "Creating DB..."
    sudo -u postgres -s createdb -O "${owner_atlas}" "${db_name}"
}

function createDatabaseExtensions() {
    printMsg "Adding extensions to DB..."
    executeQueryAsSU "CREATE EXTENSION IF NOT EXISTS postgis;"
    executeQueryAsSU "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;"
    executeQueryAsSU "COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
    executeQueryAsSU "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    executeQueryAsSU "CREATE EXTENSION IF NOT EXISTS unaccent;"
}

# Test si la base de donnée contient déja des schéma qui indique que la BDD atlas a déjà été installée
function exitOnAtlasSchemaExists() {
    local schema_atlas_exists=$(hasAtlasSchema)
    if [[ "${schema_atlas_exists}" = "t" ]]; then
        exitScript "The database already seems to contain the atlas... so we'll stop here."
    fi
}

function createForeignDataWrapper() {
    printMsg "Adding FDW and connection to the GeoNature parent DB..."
    executeQueryAsSU "CREATE EXTENSION IF NOT EXISTS postgres_fdw ;"
    executeQueryAsSU "DROP SERVER IF EXISTS geonaturedbserver CASCADE;"
    executeQueryAsSU "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${db_source_host}', dbname '${db_source_name}', port '${db_source_port}', fetch_size '${db_source_fetch_size}') ;"
    executeQueryAsSU "ALTER SERVER geonaturedbserver OWNER TO ${owner_atlas} ;"
    executeQueryAsSU "CREATE USER MAPPING FOR ${owner_atlas} SERVER geonaturedbserver OPTIONS (user '${atlas_source_user}', password '$atlas_source_pass') ;"
}

# FR: Création des schémas de la BDD
# EN: Creating DB schemes
function createDatabaseSchemas() {
    printMsg "Creating database schemas..."
    executeQuery "CREATE SCHEMA IF NOT EXISTS atlas AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS gn_meta AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS gn_synthese AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS gn_sensitivity AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS ref_geo AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS ref_nomenclatures AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS taxonomie AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS utilisateurs AUTHORIZATION "$owner_atlas" ;"
}

function createFdwTables() {
    printMsg "Creating FDW tables from GN2..."
    executeFile "${__data_dir__}/gn2/atlas_gn2.sql"
}

function createDatabaseWithoutGeonature() {
    printMsg "Creating DB structure without GeoNature database..."
    executeFile "${__data_dir__}/without_gn2/without_geonature.sql"
}


main "${@}"
