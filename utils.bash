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
function initScript() {
    # Script time
    SECONDS=0
    readonly __time_start__="$(date +%s)"
    readonly __fmt_time_start__="$(date -d @${__time_start__} "+%Y-%m-%d %H:%M:%S")"

    # Useful paths
    readonly __orig_cwd__="$PWD"
    readonly __script_path__=$(realpath "${BASH_SOURCE[1]}")
    readonly __script_dir__="$(cd "$(dirname "${__script_path__}")" && pwd -P)"
    readonly __script_name__="$(basename "$__script_path__")"
    readonly __script_params__="$*"

    #+------------------------------------------------------------------      +
    # Directories pathes
    readonly __root_dir__="$(realpath ${__script_dir__})"
    readonly __src_dir__="${__root_dir__}/atlas"
    readonly __conf_dir__="${__src_dir__}/configuration"
    readonly __data_dir__="${__root_dir__}/data"
    readonly __log_dir__="${__root_dir__}/log"
    readonly __static_dir__="${__src_dir__}/static"
    readonly __custom_dir__="${__static_dir__}/custom"

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
#       In script use :
#           `>&3` to redirect to original stdOut
#           `>&4` to redirect to original stdErr
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
    exec > >(tee -a >(sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | sed -r "s/--> /${__sep__}/g" > "${log_file}") | sed -r "s/--> //g" >&2)
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
