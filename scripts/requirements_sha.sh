#!/bin/bash
set -e

eval "$(jq -r '@sh "NAME=\(.name) REQUIREMENTS_FILE=\(.requirements_file)"')"

if [ "$REQUIREMENTS_FILE" != "null" ]; then
  current_requirements_sha=$(echo "$NAME" | cat - "${REQUIREMENTS_FILE}" | shasum -a 256 | cut -d " " -f 1)
else
  current_requirements_sha=$(echo "$NAME" | shasum -a 256 - | cut -d " " -f 1)
  # >&2 echo "$current_requirements_sha"
  # exit 0
fi

jq -n --arg requirements_sha "$current_requirements_sha" '{"sha":$requirements_sha}'
