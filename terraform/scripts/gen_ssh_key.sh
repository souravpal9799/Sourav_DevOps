#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="$SCRIPT_DIR/../keys"
mkdir -p "$KEYS_DIR"

KEY_PATH="$KEYS_DIR/terraform-key"
if [ ! -f "$KEY_PATH" ]; then
  ssh-keygen -t rsa -b 4096 -m PEM -f "$KEY_PATH" -N "" -C tf-key >/dev/null
fi

ls -l "$KEY_PATH"*


