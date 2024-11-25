#!/bin/bash - 
#===============================================================================
#
#          FILE: download-prerequisites.sh
# 
#         USAGE: ./2-download-prerequisites.sh
# 
#   DESCRIPTION: Downloads dependencies for the docker images build.
#                ⚠️  Set versions in .env before running this script.
# 
#        AUTHOR: Nicolas Broussard (nicolas@togetherfor.it)
#  ORGANIZATION: Together for it
#       CREATED: 11/15/2024 15:32:16 CET
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Load versions and paths from .env
source .env

# Prepare download URLs and destination paths
VB_DOWNLOAD_ROOT="https://bitbucket.org/art-uniroma2/vocbench3/"
VB_DOWNLOAD_PATH="downloads/vocbench3-${VB_VERSION}-full.zip"
VB_SOURCE_URL="${VB_DOWNLOAD_ROOT%/}/${VB_DOWNLOAD_PATH}"
VB_COPY_PATH_1="${VB_VERSION}/vocbench3-${VB_VERSION}-full.zip"
VB_COPY_PATH_2="helpers/graphdb-with-st-sails/vocbench3-${VB_VERSION}-full.zip"
VB_DESTINATION_1="${VB_CLONE_DIR%/}/${VB_COPY_PATH_1}"
VB_DESTINATION_2="${VB_CLONE_DIR%/}/${VB_COPY_PATH_2}"

LUCENE_DOWNLOAD_ROOT="https://github.com/Ontotext-AD/graphdb-lucene-fts-plugin/"
LUCENE_DOWNLOAD_PATH="archive/refs/tags/${LUCENE_VERSION}.zip"
LUCENE_SOURCE_URL="${LUCENE_DOWNLOAD_ROOT%/}/${LUCENE_DOWNLOAD_PATH}"
LUCENE_COPY_PATH="helpers/graphdb-with-st-sails/lucene-fts-plugin-graphdb-plugin.zip"
LUCENE_DESTINATION="${VB_CLONE_DIR%/}/${LUCENE_COPY_PATH}"

SV_DOWNLOAD_ROOT="https://bitbucket.org/art-uniroma2/showvoc/"
SV_DOWNLOAD_PATH="downloads/showvoc-${SV_VERSION}-full.zip"
SV_SOURCE_URL="${SV_DOWNLOAD_ROOT%/}/${SV_DOWNLOAD_PATH}"
SV_COPY_PATH="${SV_VERSION}/showvoc-${SV_VERSION}-full.zip"
SV_DESTINATION="${SV_CLONE_DIR%/}/${SV_COPY_PATH}"

function download() {
    NAME="$1"
    SOURCE_URL="$2"
    DESTINATION="$3"
    if [ ! -f "${DESTINATION}" ]; then
        echo "Downloading ${NAME}..."
	mkdir -p "$(dirname ${DESTINATION})"
        wget -q --show-progress -O "${DESTINATION}" "${SOURCE_URL}"
        echo "✅ ${NAME} downloaded at ${DESTINATION}"
    else
        echo "✅ ${NAME} found at ${DESTINATION}"
    fi
}

function link() {
    NAME="$1"
    SOURCE_FILE="$2"
    DESTINATION="$3"
    if [ ! -f "${DESTINATION}" ]; then
        echo "Linking ${NAME}..."
        ln "${SOURCE_FILE}" "${DESTINATION}"
        echo "✅ ${NAME} linked at ${DESTINATION}"
    else
        echo "✅ ${NAME} found at ${DESTINATION}"
    fi
}

download "VocBench full distribution" "${VB_SOURCE_URL}" "${VB_DESTINATION_1}"
download "GraphDB Lucene FTS plugin" "${LUCENE_SOURCE_URL}" "${LUCENE_DESTINATION}"
link "VocBench for GraphDB Lucene FTS" "${VB_DESTINATION_1}" "${VB_DESTINATION_2}"
download "ShowVoc full distribution" "${SV_SOURCE_URL}" "${SV_DESTINATION}"

echo "Prerequisites are ready for deployment."
exit 0

