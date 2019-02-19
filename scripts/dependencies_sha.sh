#!/bin/bash
set -e

eval "$(jq -r '@sh "NAME=\(.name) DEPENDENCIES_FILE=\(.modules_file)"')"

if [ "$DEPENDENCIES_FILE" != "null" ]; then
  current_sha=$(shasum -a 256 "${DEPENDENCIES_FILE}" | cut -d " " -f 1)
  
else
  current_sha=$(echo "$NAME" | shasum -a 256 - | cut -d " " -f 1)
fi

jq -n --arg dep_sha "$current_sha" '{"sha":$dep_sha}'