#!/bin/bash

set -e

PYTHON_RUNTIME=$1
REQUIREMENTS_FILE=$2
REQUIREMENTS_SHA=$3

WORK_DIR=${TMPDIR}${REQUIREMENTS_SHA}

echo "INFO: Using work dir $WORK_DIR"

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

PYTHON_VERSIONS="python2.7 python3.6 python3.7"

if ! [[ $PYTHON_VERSIONS =~ (^|[[:space:]])$PYTHON_RUNTIME($|[[:space:]]) ]]; then
  echo "ERROR: Invalid python runtime $PYTHON_RUNTIME"
  exit 1
fi

# We need to grab pyenv
# pyenv generally exists as a shell function, but that's not what we want
# Instead, we want to reach to the explicit, expected install location of
# pyenv, and, instead of initialising it into our subshell:
# - list out the versions
# - Get the shim path
# - Directly use the pyenv binary
# - directly use the pyenv-virtualenv binary

# This should make it easier to control whether or not we're doing
# something reasonable here.

PYENV="/usr/local/bin/pyenv"
VIRTUALENV="/usr/local/bin/pyenv-virtualenv"

# eval "$(pyenv init -)"
MAJOR_VERSION=$(echo $PYTHON_RUNTIME | sed 's/python//')

VERSIONS=$(${PYENV} versions --bare | grep -e "$MAJOR_VERSION" | grep -e "[0-9]\.[0-9]\.[0-9]" | awk 'BEGIN { FS="/"; } {print $1}' |  uniq | sort -r )

PYENV_ROOT=$(${PYENV} root)

# Expand the VERSIONS string into a fully-fledged array
# Not sure how else to do this
for version in $VERSIONS; do
  VERSION=$version
  break
done

echo "INFO: using python version $VERSION"
# Versions should be an array now

# pyenv shell $VERSION
PYTHON=${PYENV_ROOT}/versions/${VERSION}/bin/python
VIRTUALENV=${PYENV_ROOT}/versions/${VERSION}/bin/virtualenv

# Okay cool let's build us a virtualenv!

echo "INFO: Building virtualenv at $WORK_DIR"
${VIRTUALENV} --always-copy $WORK_DIR > /dev/null 2>&1

if [ "$REQUIREMENTS_FILE" != "null" ]; then
  echo "INFO: Installing from pip"
  ${WORK_DIR}/bin/pip install -r ${REQUIREMENTS_FILE}
fi

# Okay, we're done building the virtualenv
