#!/bin/bash

# $1 is a human-readable name to make error logs more useful
# $2 is the requirements sha

set -e

WORK_DIR="${TMPDIR}${2}"
echo "INFO: Attempting to make temporary directory $WORK_DIR"
# TODO: Is this the best way of expressing the "is the variable null"?
if [ "$TMPDIR " == " " ]; then
  echo "ERROR: while making $1, found null TMPDIR"
  exit 1
fi

if [ -d $WORK_DIR ]; then
  # It already exists 
  # This means that: we haven't been given a requirements.txt
  # (since the sha256) isn't unique
  # And
  # something else is using the same name for the build
  # So we need to error
  echo "WARN: While making $1, temporary directory already exists"
  echo "WARN: Deleting!"
  # TODO: Make this a lot more defensive than it is
  rm -rf $WORK_DIR
fi

mkdir $WORK_DIR

if ! [ -d $WORK_DIR ]; then
  echo "ERROR: $1 work directory could not be created"
  exit 1
fi