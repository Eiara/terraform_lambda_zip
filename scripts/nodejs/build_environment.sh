#!/bin/bash

set -e 

PROJECT_DIR=$PROJECT_DIR
DEPENDENCIES_SHA=$DEPENDENCIES_SHA
CUSTOM_COMMANDS=$CUSTOM_COMMANDS

echo "INFO: Using work dir $WORK_DIR"
WORK_DIR=${TMPDIR}${DEPENDENCIES_SHA}

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

# Copy everything to the work dir

pushd $PROJECT_DIR
cp -R * $WORK_DIR

# Install from npm

npm install

# Allows injection of things like 'npm run transpile'
eval "${CUSTOM_COMMANDS}"

popd