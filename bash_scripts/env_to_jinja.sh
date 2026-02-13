#!/usr/bin/env bash

BASE_DIR="/mnt/c/Users/Abhishek/Documents/call-mama/prod"   # e.g. /var/www or your repo root

find "$BASE_DIR" -type f -name ".env.j2" | while read -r file; do
  echo "Processing: $file"

  sed -i -E '
    /^[[:space:]]*#/b;
    /^[[:space:]]*$/b;
    s/^([A-Za-z_][A-Za-z0-9_]*)=.*/\1={{\1}}/
  ' "$file"

done
