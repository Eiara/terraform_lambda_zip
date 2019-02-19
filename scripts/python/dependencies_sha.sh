#!/bin/bash
set -e

eval "$(jq -r '@sh "NAME=\(.name) REQUIREMENTS_FILE=\(.modules_file)"')"

if [ "$REQUIREMENTS_FILE" != "null" ]; then
  current_requirements_sha=$(shasum -a 256 "${REQUIREMENTS_FILE}" | cut -d " " -f 1)
  
else
  current_requirements_sha=$(echo "$NAME" | shasum -a 256 - | cut -d " " -f 1)
  # >&2 echo "$current_requirements_sha"
  # exit 0
fi

jq -n --arg requirements_sha "$current_requirements_sha" '{"sha":$requirements_sha}'