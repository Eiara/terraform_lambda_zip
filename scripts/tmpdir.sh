#!/bin/bash

jq -n --arg dir "$TMPDIR" '{"tmpdir":$dir}'