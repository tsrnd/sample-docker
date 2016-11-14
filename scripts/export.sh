#!/bin/bash
set -eu -o pipefail

while read -r LINE; do
    echo "export $LINE"
done < $1
