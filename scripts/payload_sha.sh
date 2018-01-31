#!/bin/bash

set -e

eval "$(jq -r '@sh "NAME=\(.name) OUTPUT_PATH=\(.output_path)"')"

if ! [ -f ${OUTPUT_PATH}/${NAME}_payload.zip ]; then
  >&2 echo "ERROR: No payload zip!"
fi

sha=$(shasum -a 256 ${OUTPUT_PATH}/${NAME}_payload.zip | cut -d " " -f 1 | base64 -)

jq -n --arg sha "$sha" '{"sha":$sha}'