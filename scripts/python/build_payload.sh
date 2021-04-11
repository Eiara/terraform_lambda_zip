#!/bin/bash
set -e

NAME=$PAYLOAD_NAME
RUNTIME=$PAYLOAD_RUNTIME
PYTHON_PROJECT=$PROJECT_PATH
# WORK_DIR_SHA=$PROJECT_SHA
VIRTUALENV_SHA=$DEPENDENCIES_SHA
# $WORK_SHA
# OUTPUT_PATH=$6
# FILENAME=$7


if ! [ -d $OUTPUT_PATH ]; then
  echo "ERROR: Output path is missing"
  exit 1
fi

PYTHON_VERSIONS="python2.7 python3.6 python3.7  python3.8"

if ! [[ $PYTHON_VERSIONS =~ (^|[[:space:]])$RUNTIME($|[[:space:]]) ]]; then
  echo "ERROR: Invalid python runtime $PYTHON_RUNTIME"
  exit 1
fi

VIRTUALENV="${TMPDIR}${WORK_SHA}"
SITE_PACKAGES="${VIRTUALENV}/lib/${RUNTIME}/site-packages/"
BIN="$VIRTUALENV/bin"
WORK_DIR="${TMPDIR}${WORK_SHA}"

if ! [ -d $SITE_PACKAGES ]; then 
  echo "ERROR: Site packages missing!"
  echo "ERROR: $SITE_PACKAGES"
  exit 1
fi

if ! [ -d $PYTHON_PROJECT ]; then
  echo "ERROR: Missing python project directory"
  exit 1
fi

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: Work directory doesn't exist!"
  echo "ERROR: $WORK_DIR"
  exit 1
fi

# Okay, let's make the virtualenv zip

echo "INFO: Building virtualenv zip archive"
pushd $SITE_PACKAGES
${BIN}/python -m compileall . > /dev/null 2>&1

# Exclude all the default python stuff that's unnecessary in the default context

zip -r -q virtualenv.zip . -x "pip*" -x "setuptools*" -x "wheel*" -x easy_install.py -x "__pycache__/easy_install*" -x "*.dist-info*" -x "boto3*" -x "botocore*"

# zip -r -q virtualenv.zip .

if ! [ -e $SITE_PACKAGES/virtualenv.zip ]; then
  # Uh
  # Well
  # that's bad?
  # Something went wrong?
  echo "ERROR: Missing virtualenv archive at $SITE_PACKAGES/virtualenv.zip"
  exit 1
fi

# Move back to where we started
popd

# Cool
# There'll always be a virtualenv, because we need to create a clean build 
# point for our python package
# There'll always be a project (why would there not be? That's just weird!)

# Okay
# Step 1: copy the project from where it is to the workdir

echo "INFO: current working directory is ${PWD}"

cp -r $PYTHON_PROJECT ${WORK_DIR}

BASENAME=$(basename $PYTHON_PROJECT)

pushd ${WORK_DIR}/${BASENAME}

# Compile the python package into pycs and such
# This improves startup time for lambda packages, since pycs are only valuable
# for application startup times
${BIN}/python -m compileall . > /dev/null 2>&1

cp $SITE_PACKAGES/virtualenv.zip .

# Build the zipfile, exclude git stuff, and exclude the requirements.txt, if it exists
echo "building payload zip"
zip -q -r virtualenv.zip ./* -x .git -x requirements.txt

popd

# Output path is expected to be a fully qualified filename
mv ${WORK_DIR}/${BASENAME}/virtualenv.zip ${OUTPUT_PATH}/${FILENAME}
