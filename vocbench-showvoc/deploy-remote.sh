#!/bin/bash - 
#===============================================================================
#
#          FILE: deploy-remote.sh
# 
#         USAGE: ./deploy-remote.sh <REMOTE_IP>
# 
#   DESCRIPTION: Deploys VocBench and ShowVoc on a remote machine.
# 
#        AUTHOR: Nicolas Broussard (nicolas@togetherfor.it)
#  ORGANIZATION: Together for it
#       CREATED: 11/15/2024 16:23:32 CET
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

show_help(){
cat <<-EOF

Deploys VocBench and ShowVoc remotely.

Prerequisite: add an allowed SSH key to your SSH agent (see USAGE).

${b}${yellow}USAGE${white}${n}: 
    ssh-add /path/to/ssh/key/giving/you/access/to/remote_ip
    ${0} <REMOTE_IP>

EOF
}

# Fetch params
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

deployment_dir="${SCRIPT_PATH}/deployment"
deploy_script="3-deploy.sh"
ssh_ip="$1"
ssh_workdir=/srv/dfc

# Load ssh utility functions
. includes/ssh-utils.sh

# Hide setlocale warnings
# Locales get installed by the first deployment script.
export LC_ALL=C
export LANG=C

# Create workdir
ssh_exec "if [ ! -d ${ssh_workdir} ]; then
    sudo mkdir -p ${ssh_workdir};
    sudo chown \$USER ${ssh_workdir};
fi"

# Upload and run scripts on server
if [ -f ${deployment_dir%/}/${deploy_script} ]; then
    echo
    echo "${b}Uploading deployment code to server…${n}"
    echo
    ssh_copy_to_remote "${deployment_dir%/}"/ "."
    echo "${b}Deployment code uploaded.${n}"

    echo
    echo "${b}Running deploy script on server…${n}"
    echo
    ssh_exec "cd ${ssh_workdir} && 
              ./${deployment_dir##*/}/${deploy_script##*/} --with-instance-init"
else
    echo "${red}ERROR: no deploy scripts at ${deploy_script} .${n}"
	  exit 1
fi

exit 0

