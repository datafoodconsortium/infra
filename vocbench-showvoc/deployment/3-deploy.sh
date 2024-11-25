#!/bin/bash - 
#===============================================================================
#
#          FILE: 3-deploy.sh
# 
#         USAGE: ./3-deploy.sh
# 
#   DESCRIPTION: Deploys VocBench and ShowVoc locally.
#                Set version numbers in .env before running this script.
# 
#        AUTHOR: Nicolas Broussard (nicolas@togetherfor.it)
#  ORGANIZATION: Together for it
#       CREATED: 11/21/2024 15:46:50 CET
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "${SCRIPT_PATH}"

# Load variables from .env
source .env

# If specified, run init script (idempotent)
if [[ "$1" == "--with-instance-init" ]]; then
    ./0-init-instance.sh
fi

# Run setup scripts (idempotent)
./1-clone-repos.sh
./2-download-prerequisites.sh

# Deploy services
docker compose up -d --build

echo "🍺 ShowVoc and VocBench are deployed."
echo "   https://${VB_DOMAIN}/vocbench3"
echo "   https://${SV_DOMAIN}/showvoc"

cd - > /dev/null
exit 0

