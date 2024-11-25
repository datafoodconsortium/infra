#!/bin/bash - 
#===============================================================================
#
#          FILE: 1-clone-repos.sh
# 
#         USAGE: ./1-clone-repos.sh
# 
#   DESCRIPTION: Clones and checks out the required repos at given version tags.
#                ⚠️  Set versions in .env before running this script.
# 
#        AUTHOR: Nicolas Broussard (nicolas@togetherfor.it)
#  ORGANIZATION: Together for it
#       CREATED: 11/21/2024 15:46:50 CET
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

# Load version and paths from .env
source .env

# Define extra variables
VB_REPO_URL="https://bitbucket.org/art-uniroma2/vocbench3-docker.git"
SV_REPO_URL="https://bitbucket.org/art-uniroma2/showvoc-docker.git"

function clone_and_checkout_at() {
    REPO_NAME="$1"
    REPO_URL="$2"
    REPO_VERSION="$3"
    CLONE_DIR="$4"

    # Clone repository
    if [ ! -d "${CLONE_DIR}" ]; then
        echo "Cloning the ${REPO_NAME} repository..."
        git clone "${REPO_URL}" "${CLONE_DIR}"
    fi
    
    # Navigate to the cloned repository directory
    cd "${CLONE_DIR}"
    
    # Check out at REPO_VERSION
    echo "Checking out ${REPO_NAME} tag ${REPO_VERSION}..."
    git checkout ${REPO_VERSION}
    echo "✅ Checked out ${REPO_NAME} tag ${REPO_VERSION} in ${CLONE_DIR}"
    cd -
}

clone_and_checkout_at "VocBench" \
    "${VB_REPO_URL}" "${VB_VERSION}" "${VB_CLONE_DIR}"

clone_and_checkout_at "ShowVoc" \
    "${SV_REPO_URL}" "${SV_VERSION}" "${SV_CLONE_DIR}"

exit 0

