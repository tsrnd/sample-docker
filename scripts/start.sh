#!/bin/bash
set -eu -o pipefail

eval $(bash scripts/export.sh server.env)
npm prune
npm install
node server.js
