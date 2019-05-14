#!/bin/bash

WORK_DIR="${TMPDIR}${1}"

# TODO
# Improve defensive options here

if [[ "${1} " = " " ]] ; then
  echo "Error: no SHA specified"
  exit 1
fi

if [ "${TMPDIR} " == " " ] || [ "${1}" == "/" ] ; then
  echo "ERROR: unsafe TMPDIR or SHA path"
  exit 1
fi

# THIS MAKES ME SO NERVOUS OMG
if [[ -d $WORK_DIR ]] ; then
  rm -rf $WORK_DIR
fi