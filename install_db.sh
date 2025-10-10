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
    source "${current_dir}/utils.bash"

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
        'ATLAS_TYPE_TERRITOIRE' 'ATLAS_TYPE_CODE' 'ATLAS_TYPE_MAILLE' 'ATLAS_ALTITUDES' \
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

function checkSettings() {
    fields=('owner_atlas' 'user_pg' 'altitudes' 'time')
    printMsg "Checking the validity of settings.ini..."
    for i in "${!fields[@]}"; do
        if [[ -z "${!fields[$i]}" ]]; then
            exitScript "Attribut ${fields[$i]} manquant dans settings.ini" 2
        fi
    done
    printInfo ">All required settings are present => ${Gre}OK"
}

function exportPostgresPassword() {
    export PGPASSWORD="${owner_atlas_pass}"
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
    executeFile "data/gn2/atlas_gn2.sql"
}

function createDatabaseWithoutGeonature() {
    printMsg "Creating DB structure without GeoNature database..."
    executeFile "data/atlas/without_geonature.sql"
}

function prepareAltitudesValues() {
    printMsg "Preparing altitudes values..."
    insert_altitudes_values=""
    local i=0
    local sql=""
    for i in "${!altitudes[@]}"; do
        if [[ $i -gt 0 ]]; then
            let max=${altitudes[$i]}-1
            sql="(${altitudes[$i-1]}, $max)"
            if [[ $i -eq 1 ]]; then
                insert_altitudes_values=" ${sql}"
            else
                insert_altitudes_values="${insert_altitudes_values}, ${sql}"
            fi
        fi
    done
    if [[ "${insert_altitudes_values}" != "" ]]; then
        printInfo ">${i} altitudes ranges defined => ${Gre}OK"
    else
        printInfo ">No altitude range defined => ${Red}KO"
    fi
}

# FR: Execution des scripts sql de création des entités (vues materialisés, tables) de l'Atlas
# EN: Run sql scripts : build Atlas materialized views, tables...
function createAtlasSchemaEntities() {
    printMsg "Creating materialized views..."
    local scripts_sql=(
        "01.vm_taxref.sql"
        "02.ref_geo.sql"
        "03.bdc_statut.sql"
        "04.cor_sensitivity_area_type.sql"
        "05.vm_observations.sql"
        "06.vm_cor_area_synthese.sql"
        "07.vm_taxons.sql"
        "08.vm_altitudes.sql"
        "09.vm_search_taxon.sql"
        "10.vm_mois.sql"
        "11.vm_medias.sql"
        "12.vm_cor_taxon_attribut.sql"
        "13.vm_taxons_plus_observes.sql"
        "14.vm_cor_taxon_organism.sql"
        "15.vm_cor_maille_observation.sql"
        "16.territory_stats.sql"
        "17.grant.sql"
        "18.refresh_materialized_view_data.sql"
    )
    local script=""
    local msg=""
    local time_start=0
    local time_diff=0
    # 'set +e' : prevents the script from stopping if Psql returns a non-zero code
    set +e
    for script in "${scripts_sql[@]}"; do
        printInfo ">[$(date +'%H:%M:%S')] Creating ${script}..."
        time_start="${SECONDS}"
        executeFile data/atlas/${script} \
                -v "ON_ERROR_STOP=1" \
                -v type_territoire="${type_territoire}" \
                -v type_code="${type_code}" \
                -v type_maille="${type_maille}" \
                -v insert_altitudes_values="${insert_altitudes_values}" \
                -v taxon_time="${time}" \
                -v reader_user="${user_pg}"

        script_result=$?
        time_diff="$((${SECONDS} - ${time_start}))"
        if [[ ${script_result} -ne 0 ]]; then
            exitScript "ERROR: failed to execute ${script} !" 1
        else
            msg="${script} => ${Gre}Passed${RCol} - Duration : $(displayTime ${time_diff})"
            printInfo ">[$(date +'%H:%M:%S')] ${msg}\n"
        fi
    done
    set -e
}

function executeQueryAsSU() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

    sudo -u postgres -s psql -d "${db_name}" -c "${1}"
}

function executeQuery() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    local query="${1}"
    shift # Remove first argument so that $@ contains only other arguments
    local other_arguments=("$@")

    export PGPASSWORD="${owner_atlas_pass}"; \
        psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" \
            "${other_arguments[@]}" \
            -c "${query}"
}

function executeFile() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    local file_path="${1}"
    shift # Remove first argument so that $@ contains only other arguments
    local other_arguments=("$@")

    export PGPASSWORD="${owner_atlas_pass}"; \
        psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" \
            "${other_arguments[@]}" \
            -f "${file_path}"
}

main "${@}"
