#!/bin/bash

set -e

eval "$(jq -r '@sh "FILENAME=\(.filename)"')"

if ! [ -f ${FILENAME} ]; then
  >&2 echo "ERROR: No payload zip!"
fi

sha=$(shasum -a 256 ${FILENAME} | cut -d " " -f 1 | base64 -)
md5=$(md5 -q ${FILENAME})

jq -n --arg sha "$sha" --arg md5 "$md5" '{"sha":$sha, "md5": $md5}'