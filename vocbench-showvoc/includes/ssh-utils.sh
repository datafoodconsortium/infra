#!/bin/bash - 
#===============================================================================
#
#          FILE: ssh_utils.sh
# 
#         USAGE: . ./ssh_utils.sh
# 
#   DESCRIPTION: This file contains utility SSH functions for more clarity in
#                scripts.
# 
#        AUTHOR: Nicolas Broussard (nico.broussard@gmail.com)
#  ORGANIZATION: Together for good!
#       CREATED: 08/28/21 15:41:02 CEST
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

red=$(tput setaf 1 2>/dev/null || echo -e "\e[91m")
green=$(tput setaf 2 2>/dev/null || echo -e "\e[92m")
yellow=$(tput setaf 3 2>/dev/null || echo -e "\e[93m")
blue=$(tput setaf 4 2>/dev/null || echo -e "\e[94m")
magenta=$(tput setaf 5 2>/dev/null || echo -e "\e[95m")
cyan=$(tput setaf 6 2>/dev/null || echo -e "\e[96m")
white=$(tput setaf 7 2>/dev/null || echo -e "\e[97m")
b=$(tput bold 2>/dev/null || echo -e "\e[1m")
u=$(tput rmul 2>/dev/null || echo -e "\e[4m")
n=$(tput sgr0 2>/dev/null || echo -e "\e[0m")

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ssh_ip="${ssh_ip:-}"
ssh_port="22"
ssh_user="debian"
ssh_workdir="/srv/dfc"

# Execute a command on remote server by SSH
function ssh_exec {
    declare ssh_command=$1
    declare dry_run=${2:-}
    declare quiet=""; if [[ ! "${VERBOSE:-}" == "-v" ]]; then quiet="-q"; fi
    [[ "$dry_run" == "--dry-run" ]] && shift
    shift
    declare command=(
        ssh ${quiet} \
            ${ssh_user}@${ssh_ip} \
            -t \
            -p ${ssh_port} \
            "${ssh_command} $@"
    )

    if [[ "$dry_run" == "--dry-run" ]]; then
        echo "(dry-run) ${command[@]}"
    else
        eval '${command[@]}'
    fi
}

# Execute a script on remote server by SSH
function ssh_exec_script {
    declare ssh_script=$1
    declare dry_run=${2:-}
    declare quiet=""; if [[ ! "${VERBOSE:-}" == "-v" ]]; then quiet="-q"; fi
    [[ "$dry_run" == "--dry-run" ]] && shift
    shift
    declare command=(
        ssh ${quiet} \
            ${ssh_user}@${ssh_ip} \
            -t \
            -p ${ssh_port} \
            'bash -s'
    )

    if [[ "$dry_run" == "--dry-run" ]]; then
        echo "(dry-run) ${command[@]} < ${ssh_script} $@"
    else
        eval ${command[@]} < ${ssh_script} $@
    fi
}

# Copy file from source to remote target (<ssh_user>@<ssh_ip>:<ssh_workdir>)
function ssh_copy_to_remote {
    declare source=$1
    declare target=$2
    declare dry_run=${3:-}
    declare quiet=""; if [[ ! "${VERBOSE:-}" == "-v" ]]; then quiet="-q"; fi
    declare command=(
        scp ${quiet} \
            -P ${ssh_port} \
            -r ${source} \
            ${ssh_user}@${ssh_ip}:${ssh_workdir}/${target}
    )

    if [[ "$dry_run" == "--dry-run" ]]; then
        echo "(dry-run) ${command[@]}"
    else
        eval ${command[@]}
    fi
}

