#!/bin/bash

set -e

eval "$(jq -r '@sh "FILENAME=\(.filename)"')"

if ! [ -f ${FILENAME} ]; then
  jq -n --arg sha "" --arg md5 "" '{"sha":$sha, "md5": $md5}'
  exit 0
  >&2 echo "ERROR: No payload zip!"
fi

sha=$(openssl dgst -sha256 -binary ${FILENAME} | openssl enc -base64)
md5=$(md5 -q ${FILENAME})

jq -n --arg sha "$sha" --arg md5 "$md5" '{"sha":$sha, "md5": $md5}'