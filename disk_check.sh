#!/bin/bash
# Change made
set -euo pipefail

THRESHOLD=${1:-80}

usage=$(df --output=pcent / | tail -1 | tr -dc '0-9')

if [ "$usage" -ge "$THRESHOLD" ]; then
    echo "WARNING: root disk is ${usage}% full (limit ${THRESHOLD}%)" >&2
    exit 1
fi

echo "OK: root disk at ${usage}%"
