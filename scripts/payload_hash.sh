#!/bin/bash

set -e

eval "$(jq -r '@sh "NAME=\(.name) OUTPUT_PATH=\(.output_path)"')"

if ! [ -f ${OUTPUT_PATH}/${NAME}_payload.zip ]; then
  >&2 echo "ERROR: No payload zip!"
fi

sha=$(shasum -a 256 ${OUTPUT_PATH}/${NAME}_payload.zip | cut -d " " -f 1 | base64 -)
md5=$(md5 -q $OUTPUT_PATH/${NAME}_payload.zip)

jq -n --arg sha "$sha" --arg md5 "$md5" '{"sha":$sha, "md5": $md5}'