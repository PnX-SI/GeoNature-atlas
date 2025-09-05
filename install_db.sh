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
            "--"*) exitScript "ERROR: parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "hvx" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") readonly debug=true; set -x ;;
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
    redirectOutput "${__log_dir__}/install_db.log"

    checkNoUserRoot
    checkSuperuser

    source "${__conf_dir__}/settings.ini"
    export PGPASSWORD="${owner_atlas_pass}";
    checkSettings

    #+-------------------------------------------------------------------------+
    # Start install database
    printInfo "${__script_name__} script started at: ${__fmt_time_start__}"

    if checkDatabaseExists "${db_name}"; then
        dropDatabase
    fi

    if ! checkDatabaseExists $db_name; then
        createDatabase
    fi

    # Test if the Atlas DB is already installed
    # Disabled untile we find a better way to check if the DB is already installed
    #checkDatabaseInstalled

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
    createDatabaseEntities

    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}

# +-----------------------------------------------------------------------------------------------+
# Functions

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
    sudo -u postgres psql -c "CREATE USER ${user_pg} WITH PASSWORD '{$user_pg_pass}' ;"
    set -e

    printMsg "Creating DB..."
    sudo -u postgres -s createdb -O "${owner_atlas}" "${db_name}"

    printMsg "Adding extensions to DB..."
    executeQuery "CREATE EXTENSION IF NOT EXISTS postgis;"
    executeQuery "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;"
    executeQuery "COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
    executeQuery "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    executeQuery "CREATE EXTENSION IF NOT EXISTS unaccent;"
}

# Test si la base de donnée contient déja des schéma qui indique que la BDD atlas a déjà été installée
function checkDatabaseInstalled() {
    local query_schemas="SELECT count(*) FROM information_schema.schemata WHERE schema_name IN ('atlas', 'gn_meta', 'synthese');"
    local schema_already_exists=$(executeQuery "${query_schemas}")
    if [[ $schema_already_exists -gt 0 ]]; then
        exitScript "La base de donnée semble déjà contenir une installation de l'atlas... on s'arrête là"
    fi
}

function createForeignDataWrapper() {
    printMsg "Adding FDW and connection to the GeoNature parent DB..."
    executeQuery "CREATE EXTENSION IF NOT EXISTS postgres_fdw ;"
    executeQuery "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${db_source_host}', dbname '${db_source_name}', port '${db_source_port}', fetch_size '${db_source_fetch_size}') ;"
    executeQuery "ALTER SERVER geonaturedbserver OWNER TO ${owner_atlas} ;"
    executeQuery "CREATE USER MAPPING FOR ${owner_atlas} SERVER geonaturedbserver OPTIONS (user '${atlas_source_user}', password '$atlas_source_pass') ;"
    executeQuery "CREATE SCHEMA utilisateurs AUTHORIZATION "$owner_atlas" ;"
}

# FR: Création des schémas de la BDD
# EN: Creating DB schemes
function createDatabaseSchemas() {
    printMsg "Creating database schemas..."
    executeQuery "CREATE SCHEMA IF NOT EXISTS atlas AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS synthese AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS gn_meta AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS ref_geo AUTHORIZATION "$owner_atlas";"
    executeQuery "CREATE SCHEMA IF NOT EXISTS taxonomie AUTHORIZATION "$owner_atlas";"
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
}

# FR: Execution des scripts sql de création des entités (vues materialisés, tables) de l'Atlas
# EN: Run sql scripts : build Atlas materialized views, tables...
function createDatabaseEntities() {
    printMsg "Creating materialized views..."
    local scripts_sql=(
        "1.atlas.vm_taxref.sql"
        "1-1.atlas.ref_geo.sql"
        "1-4.cor_sensitivity_area_type.sql"
        "1-5.vm_cor_area_synthese.sql"
        "2.atlas.vm_observations.sql"
        "3.atlas.vm_taxons.sql"
        "4.atlas.vm_altitudes.sql"
        "5.atlas.vm_search_taxon.sql"
        "6.atlas.vm_mois.sql"
        "8.atlas.vm_medias.sql"
        "9.atlas.vm_cor_taxon_attribut.sql"
        "10.atlas.vm_taxons_plus_observes.sql"
        "11.atlas.vm_cor_taxon_organism.sql"
        "13.atlas.vm_observations_mailles.sql"
        "13.5.atlas.territory_stats.sql"
        "15.atlas.vm_bdc_statut.sql"
        "20.grant.sql"
        "atlas.refresh_materialized_view_data.sql"
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
        export PGPASSWORD="${owner_atlas_pass}"; \
            psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" \
                -v "ON_ERROR_STOP=1" \
                -v type_territoire="${type_territoire}" \
                -v type_code="${type_code}" \
                -v type_maille="${type_maille}" \
                -v insert_altitudes_values="${insert_altitudes_values}" \
                -v taxon_time="${time}" \
                -v reader_user="${user_pg}" \
                -f data/atlas/${script}

        script_result=$?
        time_diff="$((${SECONDS} - ${time_start}))"
        if [[ ${script_result} -ne 0 ]]; then
            exitScript "ERROR: failed to execute ${script} !" 1
        else
            msg="${script} => ${Gre}Passed${RCol} - Duration : $(displayTime ${time_diff})"
            printInfo ">[$(date +'%H:%M:%S')] ${msg}"
        fi
    done
    set -e
}

function executeQuery() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

    sudo -u postgres -s psql -d "${db_name}" -c "${1}"
}

function executeFile() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

    export PGPASSWORD="${owner_atlas_pass}"; \
        psql -d "${db_name}" -U "${owner_atlas}" -h "${db_host}" -p "${db_port}" -f "${1}"
}

main "${@}"
