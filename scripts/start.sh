#!/bin/bash
set -eux -o pipefail

eval $(bash scripts/export.sh .env)
npm config set registry http://registry.npmjs.org/

npm prune
npm install

pm2-docker app.js
