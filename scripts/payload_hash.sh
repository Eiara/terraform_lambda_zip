#!/bin/bash

set -e

eval "$(jq -r '@sh "FILENAME=\(.filename)"')"

if ! [ -f ${FILENAME} ]; then
  jq -n --arg sha "" --arg md5 "" '{"sha":$sha, "md5": $md5}'
  echo "ERROR: No payload zip at ${FILENAME}!" >&2
  exit 1
fi

sha=$(openssl dgst -sha256 -binary ${FILENAME} | openssl enc -base64)

if (which md5 > /dev/null 2>&1); then
  md5=$(md5 -q ${FILENAME})
else
  md5=($(md5sum ${FILENAME}))
fi

jq -n --arg sha "$sha" --arg md5 "$md5" '{"sha":$sha, "md5": $md5}'
