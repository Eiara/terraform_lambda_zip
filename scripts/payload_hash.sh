#!/bin/bash

set -e

eval "$(jq -r '@sh "FILENAME=\(.filename)"')"

if ! [ -f ${FILENAME} ]; then
  /usr/local/bin/jq -n --arg sha "" --arg md5 "" '{"sha":$sha, "md5": $md5}'
  exit 1
  >&2 echo "ERROR: No payload zip!"
fi

sha=$(openssl dgst -sha256 -binary ${FILENAME} | openssl enc -base64)

if (which md5 > /dev/null 2>&1); then
  md5=$(md5 -q ${FILENAME})
else
  md5=($(md5sum ${FILENAME}))
fi

/usr/local/bin/jq -n --arg sha "$sha" --arg md5 "$md5" '{"sha":$sha, "md5": $md5}'
