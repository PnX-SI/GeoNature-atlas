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
    cd "${current_dir}/"
    source "${current_dir}/utils.bash"

    #+-------------------------------------------------------------------------+
    # Init script
    initScript "${@}"
    parseScriptOptions "${@}"
    redirectOutput "${__log_dir__}/install_env.log"

    checkNoUserRoot
    checkSuperuser
    checkOs

    #+-------------------------------------------------------------------------+
    # Start install env
    printInfo "${__script_name__} script started at: ${__fmt_time_start__}"

    upgradeCurentPackages

    installGenericDependencies
    installApache
    #installPostgresql
    installPython
    installNvm

    restartApache

    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed

}

function checkOs() {
    printMsg "Checking operating system compatibility..."

    # 'set -a': exports all variables from 'os-release' here and also to subprocesses
    set -a
    source "/etc/os-release"
    set +a
    OS_NAME="${ID}"
    OS_VERSION="${VERSION_ID}"
    OS_BITS="$(getconf LONG_BIT)"

    if [ !"${OS_BITS}" == "64" ]; then
        exitScript "GeoNature must be installed on a 64-bits operating system ; your is ${OS_BITS}-bits" 1
    else
        printVerbose ">Operating system is ${OS_BITS}-bits: ${Gre}OK"
    fi

    supported_version=("12" "11")
    os_version_supported=false
    # Check if OS_VERSION is in supported_version
    for version in "${supported_version[@]}"; do
        if [[ "${OS_VERSION}" == "${version}" ]]; then
            os_version_supported=true
            break
        fi
    done
    if [[ "${OS_NAME}" != "debian" ]] || [[ "${os_version_supported}" == "false" ]]; then
        printError ">WARNING: your OS ${OS_NAME^} v${OS_VERSION} is not supported."
        printError ">Supported Debian OS in versions: ${supported_version[*]}"
        printError ">The script continues but we do not guarantee its operation..."
    else
        printVerbose ">Your Operating system is ${OS_NAME^} v${OS_VERSION}: ${Gre}OK"
    fi
}

function upgradeCurentPackages() {
    printMsg "Upgrading current OS packages..."

    sudo apt-get update
    sudo apt-get -y upgrade
}

function installGenericDependencies() {
    printMsg "Installing generic Atlas dependencies..."

    sudo apt-get install -y wget
    sudo apt-get install -y unzip
}

function installApache() {
    printMsg "Installing Apache and activating its proxy modules..."

    sudo apt-get install -y apache2
    sudo a2enmod proxy
    sudo a2enmod proxy_http
}

function installPostgresql() {
    printMsg "Installing Postgresql & Postgis..."

    if [[ "$os_version_supported" == "true" ]]; then
        printVerbose ">Install Postgresl and Postgis for ${OS_NAME} ${OS_VERSION}"
        sudo apt-get install -y postgresql
        if [[ "$OS_VERSION" == "12" ]]; then
            sudo apt-get install -y postgresql-server-dev-15
            sudo apt-get install -y postgis postgresql-15-postgis-3
        elif [[ "$OS_VERSION" == "11" ]]; then
            sudo apt-get install -y postgresql-server-dev-13
            sudo apt-get install -y postgis postgresql-13-postgis-3
        fi
    else
        printError ">ERROR: we don't install Postgresql for your OS version '$OS_VERSION'."
        printError ">Supported versions are: ${supported_version[*]}."
        printErrro ">Install Postgresql yourself."
    fi
}

function installPython() {
    printMsg "Installing Atlas Python system packages dependencies..."

    sudo apt-get install -y python3-dev libpq-dev
    sudo apt-get install -y python3-setuptools
    sudo apt-get install -y python3-pip
    sudo apt-get install -y python3-gdal gdal-bin
}

function installNvm() {
    printMsg "Installing Nvm then Node and Npm used by Atlas ..."

    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    cd "${__static_dir__}/"
    nvm install
}

function restartApache() {
    printMsg "Restarting Apache serveur..."

    sudo apachectl restart
}

main "${@}"

