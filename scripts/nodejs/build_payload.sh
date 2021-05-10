#!/bin/bash
set -e

NAME=$PAYLOAD_NAME
RUNTIME=$PAYLOAD_RUNTIME
# $PROJECT_PATH
# $PROJECT_SHA
# $DEPENDENCIES_SHA
# $FILENAME
# $OUTPUT_PATH

WORK_DIR=${TMPDIR}${WORK_SHA}
if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

NODEJS_VERSIONS="nodejs6.10 nodejs8.10 nodejs10.x nodejs12.x nodejs14.x"

if ! [[ $NODEJS_VERSIONS =~ (^|[[:space:]])$RUNTIME($|[[:space:]]) ]]; then
  echo "ERROR: Invalid nodejs runtime $RUNTIME"
  exit 1
fi

pushd $WORK_DIR

zip -q -r payload.zip .

popd # leave WORK_DIR

mv $WORK_DIR/payload.zip ${OUTPUT_PATH}/${FILENAME}
