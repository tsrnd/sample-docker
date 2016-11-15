#!/bin/bash
set -eux -o pipefail

while read -r LINE; do
    [[ -z "$LINE" ]] || echo "export $LINE"
done < $1
