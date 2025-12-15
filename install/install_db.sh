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

    if [[ "${docker:-false}" == true ]]; then
        runDockerInstall
    else
        runDefaultInstall
    fi

    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}

# +-----------------------------------------------------------------------------------------------+
# Functions

function runDefaultInstall() {
    printVerbose "Running default install..."

    checkNoUserRoot
    checkSuperuser

    source "${__conf_dir__}/settings.ini"
    checkSettings
    exportPostgresPassword

    if checkDatabaseExists "${db_name}"; then
        dropDatabase
    fi

    if ! checkDatabaseExists "${db_name}"; then
        createDatabase
    fi

    # Test if the Atlas Schema is already installed
    # Disabled until we find a better way to check if the Atlas is already installed
    #exitOnAtlasSchemaExists

    # FR: Si j'utilise GeoNature ($geonature_source = True), alors je créé les connexions en FWD à la BDD GeoNature
    # EN: If I use GeoNature ($geonature_source = True), then I create the connections in FWD to the GeoNature DB
    if ${geonature_source}; then
        createForeignDataWrapper
    fi

    createDatabaseSchemas

    if ${geonature_source}; then
        # FR: Si j'utilise GeoNature ($geonature_source = True),
        #     alors je créé les tables filles en FDW connectées à la BDD de GeoNature
        # EN: If I use GeoNature ($geonature_source = True),
        #     then I create the child tables in FDW connected to the GeoNature DB
        createFdwTables
    else
        # FR: Si je n'utilise pas GeoNature ($geonature_source = False),
        #     alors je créé une structure de BDD Atlas vide.
        # EN: If I don't use GeoNature ($geonature_source = False),
        #     then I create an empty Atlas DB structure.
        createDatabaseWithoutGeonature
    fi

    # FR: customisation de l'altitude
    # EN: customisation of altitude
    prepareAltitudesValues

    # FR: Creation des Vues Matérialisées
    # EN: Creation of Materialized Views
    createAtlasSchemaEntities
}

function runDockerInstall() {
    printVerbose "Running Docker install..."

    checkDockerVariables
    convertDockerVariables
    exportPostgresPassword

    # Test if Atlas schema exists
    local schema_atlas_exists=$(hasAtlasSchema)

    # If Atlas schema already exists
    if [[ "${schema_atlas_exists}" = "t" ]]; then
        printVerbose "Atlas schema already exists (${schema_atlas_exists})"

        if [[ "${ATLAS_DROP_SCHEMA}" = true ]]; then
            dropAtlasSchema

            # Recreate the schema
            createAtlasSchemaOnly
        else
            printVerbose "Nothing to do."
            printVerbose "To reinstall Atlas at startup set ATLAS_DROP_SCHEMA to 'true'."
        fi
    else
        printVerbose "Atlas schema does not exist (${schema_atlas_exists})."

        # Recreate the schema
        createAtlasSchemaOnly
    fi
}

function checkDockerVariables() {
    printMsg "Checking the existence of Docker environment variables..."

    local vars=(
        'POSTGRES_USER' 'POSTGRES_PASSWORD' 'POSTGRES_HOST' 'POSTGRES_DB' 'POSTGRES_PORT' \
        'ATLAS_DROP_SCHEMA' \
        'ATLAS_TYPE_CODE' 'ATLAS_ALTITUDES', 'ATLAS_TYPE_MAILLE' \
        'ATLAS_MOST_OBSERVED_TIME'
    )
    for i in "${!vars[@]}"; do
        if [[ -z "${!vars[$i]}" ]]; then
            exitScript "Variable ${vars[$i]} not set in Docker environment !" 2
        fi
    done
    printInfo ">All required Docker environment variables are set => ${Gre}OK"
}

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

function createAtlasSchemaOnly() {
    printVerbose "Start creating only the Atlas schema..."

    createDatabaseSchemas
    prepareAltitudesValues
    createAtlasSchemaEntities
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

# FR: Si la BDD existe, je verifie le parametre qui indique si je dois la supprimer ou non
# EN: If the DB exists, I check the parameter that indicates whether I should delete it or not
function dropDatabase() {
    if ${drop_apps_db}; then
        printMsg "Deleting DB..."
        set +e
        sudo -u postgres -s dropdb "${db_name}"
        drop_db_result=$?

        if [[ ${drop_db_result} -ne 0 ]]; then
            printInfo ">If necessary, close all Postgresql conections on Atlas DB with:"
            help="sudo -u postgres psql -c "
            help+="\"SELECT pg_terminate_backend(pg_stat_activity.pid) "
            help+="FROM pg_stat_activity "
            help+="WHERE pg_stat_activity.datname = '${db_name}' "
            help+="AND pid <> pg_backend_pid() ;\""
            printInfo ">>${help}"
            exitScript "ERROR: can't drop database !" 1
        else
            printVerbose ">Database exists and settings file says to delete it => ${Gre}deleted"
        fi
        set -e
    else
        printVerbose ">Database exists and settings file says not to delete it => continue"
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
    createDatabaseExtensions
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
