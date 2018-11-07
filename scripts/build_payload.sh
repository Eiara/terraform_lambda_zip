#!/bin/bash
set -e

NAME=$1
RUNTIME=$2
PYTHON_PROJECT=$3
WORK_DIR_SHA=$4
VIRTUALENV_SHA=$5
OUTPUT_PATH=$6
FILENAME=$7


if ! [ -d $OUTPUT_PATH ]; then
  echo "ERROR: Output path is missing"
  exit 1
fi

if [ $RUNTIME != "python2.7" ] && [ $RUNTIME != "python3.6" ]; then
  echo "ERROR: Invalid python runtime $RUNTIME"
  exit 1
fi

VIRTUALENV="${TMPDIR}${VIRTUALENV_SHA}"
SITE_PACKAGES="${VIRTUALENV}/lib/${RUNTIME}/site-packages/"
BIN="$VIRTUALENV/bin"
WORK_DIR="${TMPDIR}${WORK_DIR_SHA}"

if ! [ -d $SITE_PACKAGES ]; then 
  echo "ERROR: Site packages missing!"
  echo "ERROR: $SITE_PACKAGES"
  exit 1
fi

if ! [ -d $PYTHON_PROJECT ]; then
  echo "missing python project directory"
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

# Exclude all the default python stuff that's unnecessary in this context

zip -r -q virtualenv.zip . -x "pip*" -x "setuptools*" -x "wheel*" -x easy_install.py -x "__pycache__/easy_install*"

if ! [ -e $SITE_PACKAGES/virtualenv.zip ]; then
  # Uh
  # Well
  # that's bad?
  # Something went wrong?
  echo "ERROR: Missing virtualenv archive"
  exit 1
fi

# Cool
# There'll always be a virtualenv, because we need to create a clean build 
# point for our python package
# There'll always be a project (why would there not be? That's just weird!)

# Okay
# Step 1: copy the project from where it is to the workdir

cp -r $PYTHON_PROJECT ${WORK_DIR}

pushd ${WORK_DIR}

# Compile the python package into pycs and such
# This improves startup time for lambda packages, since pycs are only valuable
# for application startup times
${BIN}/python -m compileall . > /dev/null 2>&1

cp $SITE_PACKAGES/virtualenv.zip .

# Build the zipfile, exclude git stuff, and exclude the requirements.txt, if it exists
echo "building payload zip"
zip -q -r virtualenv.zip . -x .git -x requirements.txt

# Output path is expected to be a fully qualified filename
mv virtualenv.zip ${OUTPUT_PATH}/${FILENAME}