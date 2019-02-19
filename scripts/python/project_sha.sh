#!/bin/bash
set -e

eval "$(jq -r '@sh "PYTHON_PROJECT=\(.project_path)"')"

if ! [ -d $PYTHON_PROJECT ]; then
   echo "ERROR: python project does not exist!"
  exit 1
fi

if (find -s > /dev/null 2>&1); then
  >&2 echo "DEBUG: Using find -s to identify python project"
  PROJECT_HASH=$(find -s $PYTHON_PROJECT -type f -not -iname requirements.txt | cpio -o --quiet | shasum -a 256 | cut -d " " -f 1)
else
  >&2 echo "DEBUG: Using find | sort to identify python project"
  PROJECT_HASH=$(find $PYTHON_PROJECT -type f -not -iname requirements.txt | sort | cpio -o --quiet | shasum -a 256 | cut -d " " -f 1)
fi

jq -n --arg sha "$PROJECT_HASH" '{"sha": $sha}'
