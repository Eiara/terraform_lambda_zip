#!/bin/bash
set -e

NAME=$PAYLOAD_NAME
RUNTIME=$PAYLOAD_RUNTIME
# $PROJECT_PATH
WORK_DIR_SHA=$PROJECT_SHA
# $DEPENDENCIES_SHA
# $FILENAME
# $OUTPUT_PATH

WORK_DIR=${TMPDIR}${DEPENDENCIES_SHA}
if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

if [ $RUNTIME != "nodejs8.10" ] && [ $RUNTIME != "nodejs6.10" ]; then
  echo "ERROR: Invalid nodejs runtime $RUNTIME"
  exit 1
fi

pushd $WORK_DIR

zip -q -r . payload.zip

mv virtualenv.zip ${OUTPUT_PATH}/${FILENAME}

popd