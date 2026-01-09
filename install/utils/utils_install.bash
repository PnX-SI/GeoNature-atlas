#!/usr/bin/env bash

# A Bash script with many useful functions. This file is suitable for sourcing
# into other scripts and so only contains functions which are unlikely to need
# modification. It omits the following functions:
# - main()
# - parseScriptOptions()
# - printScriptUsage()

# +-----------------------------------------------------------------------------------------------+
# Functions

# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $__time_start__: The epoch time when the script started
#       $__fmt_time_start__: The formatted time when the script started
#       $__orig_cwd__: The current working directory when the script was run
#       $__script_path__: The full path to the script
#       $__script_dir__: The directory path of the script
#       $__script_name__: The file name of the script
#       $__script_params__: The original parameters provided to the script
#       $__ta_none__: The ANSI control code to reset all text attributes
#
#       See source code for more variables...
# NOTE: $__script_path__ only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $__script_dir__ and $__script_name__ variables.
# shellcheck disable=SC2034
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh

# global vars

insert_altitudes_values=""

function initScript() {
    # Script time
    SECONDS=0
    readonly __time_start__="$(date +%s)"
    readonly __fmt_time_start__="$(date -d @${__time_start__} "+%Y-%m-%d %H:%M:%S")"

    # Useful paths
    readonly __orig_cwd__="$PWD"
    readonly __script_path__=$(realpath "${BASH_SOURCE[1]}")
    readonly __script_dir__="$(dirname "$__script_path__")"
    readonly __script_name__="$(basename "$__script_path__")"
    readonly __script_params__="$*"

    #+------------------------------------------------------------------      +
    # Directories pathes
    readonly __root_dir__="$(dirname "$__script_dir__")"
    readonly __src_dir__="${__root_dir__}/atlas"
    readonly __conf_dir__="${__src_dir__}/configuration"
    readonly __data_dir__="${__root_dir__}/data"
    readonly __log_dir__="${__root_dir__}/log"
    readonly __static_dir__="${__src_dir__}/static"
    readonly __custom_dir__="${__static_dir__}/custom"
    readonly __sample_dir__="${__static_dir__}/sample"
    readonly __venv_dir__="${__root_dir__}/venv"

    #+------------------------------------------------------------------------+
    # Shell colors
    readonly RCol="\e[0m"; # Text Reset
    readonly Red="\e[1;31m"; # Text Dark Red
    readonly Gre="\e[1;32m"; # Text Dark Green
    readonly Yel="\e[1;33m"; # Text Yellow
    readonly Mag="\e[1;35m"; # Text Magenta
    readonly Gra="\e[1;30m"; # Text Dark Gray
    readonly Whi="\e[1;37m"; # Text Dark White
    readonly Std="\e[0m"; # Text normal
    readonly Blink="\e[5m"; #Text blink

    #+------------------------------------------------------------------------+
    # Section separator
    readonly __sep_limit__=100
    readonly __sep__="$(printf "=%.0s" $(seq 1 ${__sep_limit__}))\n"

    #+------------------------------------------------------------------------+
    # Important to always set as we use it in the exit handler
    readonly __ta_none__="$(tput sgr0 2> /dev/null || true)"
}

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
# NOTE: The convention used in this script for exit codes is:
#       0: Normal exit
#       1: Abnormal exit due to external error
#       2: Abnormal exit due to script error
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function exitScript() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "${1}"
        exit 0
    fi

    if [[ ${2-} =~ ^[0-9]+$ ]]; then
        if [[ ${2} -ne 0 ]]; then
            printError "${1}"
        else
            printInfo "${1}"
        fi
        exit ${2}
    fi

    exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
}

# DESC: Pretty print the provided string
#       Replace '>>>' with 3 spaces in the string. Use it to indent the message..
# ARGS: $1 (required): Message to print (defaults to a yellow)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code.
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printPretty() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

    # Replace each '>' in beginning of the message by 4 spaces
    local msg="${1}"
    local msg=$(indentMsg "${msg}")

    if [[ -n ${2-} ]]; then
        echo -e "${2}${msg}${RCol}"
    else
        echo -e "${Yel}${msg}${RCol}"
    fi
}

# DESC: Replace each '>' character at the beginning of the sting with 4 spaces.
# ARGS: $1 (required): Message to indent.
# USAGE: my_var=$(indentMsg "$my_var")
# OUTS: The string with each '>' replaced by 4 spaces.
function indentMsg() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

     # Replace each '>' in beginning of the message by 4 spaces
    local msg="${1}"

    local tab_pattern='>'
    local tab_replace='    '
    local extracted_pattern=$(echo -e "${msg}" | grep -o "^${tab_pattern}*")
    local tab_count=${#extracted_pattern}
    local indent=""
    for i in $(seq ${tab_count}); do
        indent+="${tab_replace}"
    done
    local msg=$(sed "s/^${tab_pattern}*/${indent}/g" <<< "${msg}")

    echo -e "${msg}"
}

# DESC: Print a section message
# ARGS: $1 (required): Message to print
# OUTS: None
function printMsg() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    printPretty "--> ${1}" ${Yel}
}

# DESC: Print infos message
# ARGS: $1 (required): Message to print
# OUTS: None
function printInfo() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    printPretty "${1}" ${Whi}
}

# DESC: Print an error message
# ARGS: $1 (required): Message to print
# OUTS: None
function printError() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    printPretty "${1}" ${Red}
}

# DESC: Only printPretty() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to printPretty() function
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printVerbose() {
    if [[ -n ${verbose-} ]]; then
        if [[ $# -eq 1 ]]; then
            printPretty "${1}" ${Gra}
        else
            printPretty "${@}"
        fi
    fi
}

# DESC: Redirect output
#       Send stdout and stderr in Terminal and a log file (with `tee`).
#       In Terminal: replace "--> " by empty string.
#       In logfile: replace "--> " by a separator line and remove color characters.
# ARGS: $1 (required): Log file path.
# OUTS: None
# NOTE: Directories on log file path will be create if not exist.
#       All lines with a carriage return "\r" will be removed from log file.
# SOURCE: https://stackoverflow.com/a/20564208
function redirectOutput() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi

    local log_file="${1}"
    printVerbose "Use of this log file: ${log_file}"
    local log_file_dir="$(dirname "${log_file}")"
    if [[ ! -d "${log_file_dir}" ]]; then
        printVerbose ">Create log directory..."
        mkdir -p "${log_file_dir}"
    fi
    printVerbose ">Performing redirection of all output to the log file......"
    exec &> >( \
        tee >( \
            sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | \
            sed -r "s/--> /${__sep__}/g" >> "${log_file}" \
        ) | \
        sed -r "s/--> //g" >&1 \
    )
}

# DESC: Check a binary exists in the search path
# ARGS: $1 (required): Array of names of the binary to test for existence
#       $2 (optional): Set to any value to treat failure as a fatal error
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function checkBinary() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    commands=("${@}")
    for cmd in "${commands[@]}"; do
        if ! command -v "${cmd}" > /dev/null 2>&1; then
            if [[ -n ${2-} ]]; then
                exitScript "Missing dependency: Couldn't locate: ${cmd}" 1
            else
                printError "Missing dependency: ${cmd}"
                return 1
            fi
        fi
        printVerbose "Found dependency: ${cmd} => ${Gre-}OK" ${Gra-}
    done
    return 0
}

# DESC: Validate we have superuser access as root (via sudo if requested)
# ARGS: $1 (optional): Set to any value to not attempt root access via sudo
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function checkSuperuser() {
    local superuser
    if [[ ${EUID} -eq 0 ]]; then
        superuser=true
    elif [[ -z ${1-} ]]; then
        if checkBinary "sudo"; then
            printVerbose "Sudo: Updating cached credentials ..."
            if ! sudo -v; then
                printVerbose "Sudo: Couldn't acquire credentials ..." "${Red-}"
            else
                local test_euid
                test_euid="$(sudo -H -- "${BASH}" -c 'printf "%s" "${EUID}"')"
                if [[ ${test_euid} -eq 0 ]]; then
                    superuser=true
                fi
            fi
        fi
    fi

    if [[ -z ${superuser-} ]]; then
        printVerbose "Unable to acquire superuser credentials." "${Red-}"
        return 1
    fi

    printVerbose "Successfully acquired superuser credentials => ${Gre}OK"
    return 0
}

# DESC: Show time elapsed
# ARGS: None
# OUTS: None
# NOTE: Use '__time_start__' variable define in initScript() function.
function displayTimeElapsed() {
    local time_end="$(date +%s)"
    local time_diff="$((${time_end} - ${__time_start__}))"
    printInfo "Total time elapsed: $(displayTime "${time_diff}")"
}

# DESC: Display seconds in days, hours, minutes, rest seconds
# ARGS: $1 (required): Number of seconds
# OUTS: None
# SOURCE: https://unix.stackexchange.com/a/27014
function displayTime() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    local T="${1}"
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    [[ $D > 0 ]] && printf '%d days ' $D
    [[ $H > 0 ]] && printf '%d hours ' $H
    [[ $M > 0 ]] && printf '%d minutes ' $M
    [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '
    printf '%d seconds\n' $S
}

# DESC: Check the script is NOT run as root
# ARGS: None
# OUTS: None
function checkNoUserRoot() {
    printMsg "Checking if the script is run as root..."
    if [[ "$(id -u)" == "0" ]]; then
        exitScript "ERROR: this script should NOT be run as root." 1
    else
        printInfo ">Script not running as root => ${Gre}OK"
    fi
}

# DESC: Convert Docker environment variables to settings.ini variables
# ARGS: None
# OUTS: None
function convertDockerVariables() {
    printMsg "Converting Docker environment variables..."

    # Convert ATLAS_DROP_SCHEMA to boolean
    if [[ "${ATLAS_DROP_SCHEMA}" = "true" || "${ATLAS_DROP_SCHEMA}" = 1 ]]; then
        ATLAS_DROP_SCHEMA=true
    else
        ATLAS_DROP_SCHEMA=false
    fi

    # Convert ATLAS_ALTITUDES to array
    altitudes=(${ATLAS_ALTITUDES})

    # Assign other variables
    type_code="${ATLAS_TYPE_CODE}"
    type_maille="${ATLAS_TYPE_MAILLE}"
    time="${ATLAS_MOST_OBSERVED_TIME}"

    # Assign DB connection variables
    db_name="${POSTGRES_DB}"
    db_host="${POSTGRES_HOST}"
    db_port="${POSTGRES_PORT}"
    user_pg="${POSTGRES_USER}"
    owner_atlas="${POSTGRES_USER}"
    db_user="${POSTGRES_USER}"
    user_pg_pass="${POSTGRES_PASSWORD}"
    owner_atlas_pass="${POSTGRES_PASSWORD}"
    db_password="${POSTGRES_PASSWORD}"

    printInfo ">All Docker environment variables converted => ${Gre}OK"
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
        "7.1.psql_functions.sql"
        "08.vm_altitudes.sql"
        "09.vm_search_taxon.sql"
        "10.vm_mois.sql"
        "11.vm_medias.sql"
        "12.vm_cor_taxon_attribut.sql"
        "13.vm_taxons_plus_observes.sql"
        "14.vm_cor_taxon_organism.sql"
        "14.1.vm_cor_taxon_area.sql"
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
        executeFile ${__data_dir__}/atlas/${script} \
                -v "ON_ERROR_STOP=1" \
                -v type_code="${type_code}" \
                -v type_maille="${type_maille}" \
                -v insert_altitudes_values="${insert_altitudes_values}" \
                -v taxon_time="${time}" \
                -v reader_user="${user_pg}" \
                -v observation_data_source="${observation_data_source}"

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

function executeQueryAsSU() {
    if [[ $# -lt 1 ]]; then
        exitScript "Missing required argument to ${FUNCNAME[0]}()!" 2
    fi
    if [[ "${docker:-false}" == true ]]; then
        psql -h "${db_host}" -U "${owner_atlas}" -d "${db_name}" -c "${1}"
    else
        sudo -u postgres -s psql -d "${db_name}" -c "${1}"
    fi

}



function prepareAltitudesValues() {
    printMsg "Preparing altitudes values..."
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