#!/bin/bash

set -e

PYTHON_RUNTIME=$RUNTIME
REQUIREMENTS_FILE=$DEPENDENCIES_FILE
# REQUIREMENTS_SHA=$DEPENDENCIES_SHA

WORK_DIR=${TMPDIR}${WORK_SHA}
echo "INFO: Using work dir $WORK_DIR"

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

if [ $PYTHON_RUNTIME != "python2.7" ] && [ $PYTHON_RUNTIME != "python3.6" ]; then
  echo "Invalid python runtime $PYTHON_RUNTIME"
  exit 1
fi

eval "$(pyenv init -)"
MAJOR_VERSION=$(echo $PYTHON_RUNTIME | sed 's/python//')

VERSIONS=$(pyenv versions --bare | grep -e "$MAJOR_VERSION" | grep -e "[0-9]\.[0-9]\.[0-9]" | awk 'BEGIN { FS="/"; } {print $1}' |  uniq | sort -r )

# This is ridiculous
for version in $VERSIONS; do
  VERSION=$version
  break
done

echo "INFO: using python version $VERSION"
# Versions should be an array now

pyenv shell $VERSION

# Okay cool let's build us a virtualenv!

echo "INFO: Building virtualenv at $WORK_DIR"
virtualenv --always-copy $WORK_DIR > /dev/null 2>&1

if [ "$REQUIREMENTS_FILE" != "null" ]; then
  echo "INFO: Installing from pip"
  ${WORK_DIR}/bin/pip install -r ${REQUIREMENTS_FILE}
fi

# Okay, we're done building the virtualenv