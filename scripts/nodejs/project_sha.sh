#!/bin/bash
set -e

eval "$(jq -r '@sh "PROJECT=\(.project_path)"')"

if ! [ -d $PROJECT ]; then
  >&2 echo "nodejs project $PROJECT does not exist!"
  exit 1
fi

PROJECT_HASH=$(find -s $PROJECT -type f | cpio -o --quiet | shasum -a 256 | cut -d " " -f 1)

jq -n --arg sha "$PROJECT_HASH" '{"sha": $sha}'