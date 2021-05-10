#!/bin/bash

set -e

# $PROJECT_DIR
# $DEPENDENCIES_SHA
# $CUSTOM_COMMANDS

WORK_DIR=${TMPDIR}${WORK_SHA}

echo "INFO: Using work dir $WORK_DIR"

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

# Copy everything to the work dir

pushd $PROJECT_PATH
cp -R * $WORK_DIR/
pushd $WORK_DIR

# Install from npm

npm install

# Allows injection of things like 'npm run transpile'
eval "${CUSTOM_COMMANDS}"

popd # leave WORK_DIR
popd # leave PROJECT_PATH
