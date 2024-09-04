#!/bin/bash -ev
[[ -z ${MIRROR_BUILD_DIR} ]] && export MIRROR_BUILD_DIR=${PWD}
[[ -z ${MIRROR_OUTPUT_DIR} ]] && export MIRROR_OUTPUT_DIR=${PWD}/mirror-dist
source dependencies/versions.sh
source ${MIRROR_BUILD_DIR}/common/utils.sh

CLOUDERA_REPO_FILE_LIST=$(envsubst < ${MIRROR_BUILD_DIR}/dependencies/pnda-cdh-repo-cloudera.txt)

CLOUDERA_REPO_FILE_DIR=$MIRROR_OUTPUT_DIR/mirror_cloudera
mkdir -p $CLOUDERA_REPO_FILE_DIR
cd $CLOUDERA_REPO_FILE_DIR
echo "$CLOUDERA_REPO_FILE_LIST" | while read CLOUDERA_REPO_FILE
do
    echo $CLOUDERA_REPO_FILE
    robust_curl "$CLOUDERA_REPO_FILE"
done
