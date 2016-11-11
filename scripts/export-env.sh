#!/bin/bash

while read -r LINE; do
    echo "export $LINE"
done < .env
