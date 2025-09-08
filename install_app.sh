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
    redirectOutput "${__log_dir__}/install_app.log"

    checkNoUserRoot
    checkSuperuser

    #+-------------------------------------------------------------------------+
    # Start install env
    printInfo "${__script_name__} script started at: ${__fmt_time_start__}"

    createDefaultSettingsFile
    loadSettings

    stopAtlasService
    createVenv
    enableVenv
    installPythonPackages
    disableVenv

    makeNvmAvailable
    installNodePackages

    createPythonConfigFile
    updatePythonConfigFile

    createCustomTemplates
    createCustomImages
    createOtherCustomFiles

    createAtlasService
    startAtlasService

    #+--------------------------------------------------------------------------------------------+
    # Display script execution infos
    displayTimeElapsed
}

function createDefaultSettingsFile() {
    printVerbose "Creating default settings file if it doesn't already exist..."
    if [[ ! -f "${__conf_dir__}/settings.ini" ]]; then
        cp "${__conf_dir__}/settings.ini.sample" "${__conf_dir__}/settings.ini"
    fi
}

function loadSettings() {
    printMsg "Loading settings..."
    if [[ ! -f "${__conf_dir__}/settings.ini" ]]; then
        exitScript "ERROR: settings file '${__conf_dir__}/settings.ini' not found !" 1
    fi
    # 'set -a': exports all variables from settings.ini here and also to subprocesses
    set -a
    source "${__conf_dir__}/settings.ini"
    set +a
}

function makeNvmAvailable() {
    printMsg "Making nvm available..."
    export NVM_DIR="${HOME}/.nvm"
    # This loads nvm
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
    # This loads nvm bash_completion
    [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"

    if command -v nvm &>/dev/null; then
        printVerbose ">Nvm: v$(nvm --version) => ${Gre}OK"
    else
        printError ">Nvm not loaded! Try to continue..."
    fi
}

function stopAtlasService() {
    printMsg "Stopping Atlas Systemd service..."
    # Try to stop the service if it is running, ignore errors
    sudo systemctl stop geonature-atlas || true
}

function createVenv() {
    printMsg "Creating Virtual env..."
    if [[ -d "${venv_dir}/" ]];  then
        printVerbose "Removing existing virtual env..."
        sudo rm -rf "${venv_dir}"
    fi
    virtualenv -p "${python_executable}" "${venv_dir}"
}

function enableVenv() {
    printMsg "Activating Virtual env..."
    if [[ ! -d "${venv_dir}/" ]];  then
        exitScript "ERROR: virtual env '${venv_dir}' not found !" 1
    fi
    source "${venv_dir}/bin/activate"

    local in_venv=$(isInVenv)
    if [[ "${in_venv}" == "1" ]]; then
        printVerbose ">venv activated => ${Gre}${VIRTUAL_ENV}"
    else
        printError ">venv not activated: ${in_venv}!"
    fi
}

function isInVenv() {
    local in_venv=$(python3 -c 'import sys; print ("1" if (hasattr(sys, "real_prefix") or
        (hasattr(sys, "base_prefix") and sys.base_prefix != sys.prefix)) else "0")')

    if [[ "${in_venv}" == "0" ]] && [[ "${VIRTUAL_ENV:-}" == "${venv_dir}" ]]; then
        printVerbose ">Python return false but env variable true ! Force true."
        in_venv="1"
    fi

    echo -e "${in_venv}"
}

function installPythonPackages() {
    printMsg "Installing required Python packages..."
    pip install -r requirements.txt
    pip install -e .
}

function disableVenv() {
    printMsg "Deactivating Virtual env..."
    deactivate

    local in_venv=$(isInVenv)
    if [[ "${in_venv}" == "0" ]]; then
        printVerbose ">venv deactivated => ${Gre}OK"
    else
        printError ">venv already activated!"
    fi
}

function installNodePackages() {
    printMsg "Installing required Node packages..."
    cd "${__root_dir__}/atlas/static/"
    nvm use
    npm install
    cd "${__root_dir__}/"
}

function createPythonConfigFile() {
    printMsg "Creating Python configuration file if it doesn't already exist..."
    local conf_path="${__conf_dir__}/config.py"
    if [[ ! -f "${conf_path}" ]]; then
        cp "${conf_path}.sample" "${conf_path}"
        if [[ $? -eq 0 ]]; then
           printVerbose ">Config file ${Gre}created${RCol} at: ${conf_path}"
        fi
    else
        printVerbose ">Config file already exists at: ${conf_path}"
    fi
}

function updatePythonConfigFile() {
    printMsg "Updating Python configuration file..."
    local conf_file="config.py"
    local conf_path="${__conf_dir__}/${conf_file}"

    local pg_uri="postgresql:\/\/${user_pg}:${user_pg_pass}@${db_host}:${db_port}\/${db_name}"
    sed -i "s/SQLALCHEMY_DATABASE_URI = .*$/SQLALCHEMY_DATABASE_URI = \"${pg_uri}\"/" "${conf_path}"
    if [[ $? -eq 0 ]]; then
        printVerbose ">SQLALCHEMY_DATABASE_URI ${Gre}updated${RCol} in ${conf_file}"
    fi

    sed -i "s/GUNICORN_PORT = .*$/GUNICORN_PORT = \"${gun_port}\"/"  "${conf_path}"
    if [[ $? -eq 0 ]]; then
        printVerbose ">GUNICORN_PORT ${Gre}updated${RCol} in ${conf_file}"
    fi
}

function createCustomTemplates() {
    printMsg "Creating custom templates if they don't already exist..."
    local custom_templates=(
        "bandeaulogoshome"
        "credits"
        "footer"
        "introduction"
        "mentions-legales"
        "navbar"
        "personal-data"
        "presentation"
        "statuts"
    )
    local tpl_name
    local tpl_dir="${__custom_dir__}/templates/"
    for tpl_name in "${custom_templates[@]}"; do
        if [[ ! -f "${tpl_dir}/${tpl_name}.html" ]]; then
            cp "${tpl_dir}/${tpl_name}.html.sample" "${tpl_dir}/${tpl_name}.html"
            printVerbose ">${tpl_name}.html ${Gre}created"
        fi
    done
}

function createCustomImages() {
    printMsg "Creating custom images if they don't already exists..."

    local img_dir="${__custom_dir__}/images/"
    if [[ ! -d "${img_dir}/" ]]; then
        printVerbose "Creating custom images folder..."
        mkdir -p "${img_dir}/"
    fi

    local custom_images=(
        "accueil-intro.jpg"
        "external-website.png"
        "favicon.ico"
        "logo_patrimonial.png"
        "logo_protection.png"
        "logo-structure.png"
    )
    local img_file
    for img_file in "${custom_images[@]}"; do
        if [[ ! -f "${img_dir}/${img_file}" ]]; then
            cp "${img_dir}/sample.${img_file}" "${img_dir}/${img_file}"
            printVerbose ">${img_file} ${Gre}created"
        fi
    done
}

function createOtherCustomFiles() {
    printMsg "Creating other custom files if they don't already exists..."
    local other_custom_files=(
        "templates/robots.txt"
        "custom.css"
        "glossaire.json"
        "maps-custom.js"
        "territoire.json"
    )
    local file_path
    local full_path
    for file_path in "${other_custom_files[@]}"; do
        full_path="${__custom_dir__}/${file_path}"
        if [[ ! -f "${full_path}" ]]; then
            cp "${full_path}.sample" "${full_path}"
            printVerbose ">${file_path} ${Gre}created"
        fi
    done
}

function createAtlasService() {
    printMsg "Creating Atlas Systemd service..."
    export BASE_DIR=$(readlink -e "${0%/*}")
    envsubst '${USER} ${BASE_DIR} ${gun_num_workers} ${gun_port}' \
        < geonature-atlas.service | sudo tee /etc/systemd/system/geonature-atlas.service || true
}

function startAtlasService() {
    printMsg "Launching Atlas Systemd service..."
    sudo systemctl daemon-reload || true
    sudo systemctl enable geonature-atlas || true
    sudo systemctl start geonature-atlas || true

    systemctl is-active --quiet geonature-atlas
    if [[ $? -eq 0 ]]; then
        printInfo ">${Gre}Atlas service is running !"
    else
        printError ">Atlas service is NOT running ! ${Gra}Check with: systemctl status geonature-atlas"
    fi
}

main "${@}"

