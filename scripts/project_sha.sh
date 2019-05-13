#!/bin/bash
set -e

eval "$(jq -r '@sh "PYTHON_PROJECT=\(.project_path)"')"

if ! [ -d $PYTHON_PROJECT ]; then
  >&2 echo "python project does not exist!"
  exit 1
fi

if (find -s > /dev/null 2>&1); then
  PROJECT_HASH=$(find -s $PYTHON_PROJECT -type f -not -iname requirements.txt | cpio -o --quiet | shasum -a 256 | cut -d " " -f 1)
else
  PROJECT_HASH=$(find $PYTHON_PROJECT -type f -not -iname requirements.txt | sort | cpio -o --quiet | shasum -a 256 | cut -d " " -f 1)
fi

jq -n --arg sha "$PROJECT_HASH" '{"sha": $sha}'
