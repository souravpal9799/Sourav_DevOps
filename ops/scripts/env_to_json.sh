#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${1:-}"

if [[ -z "$BASE_DIR" || ! -d "$BASE_DIR" ]]; then
  echo "Usage: $0 /path/to/directory"
  exit 1
fi

find "$BASE_DIR" -type f -name ".env" ! -name "*.j2" | while read -r ENV_FILE; do
  JSON_FILE="${ENV_FILE}.json"

  echo "🔄 Converting: $ENV_FILE → $JSON_FILE"

  {
    echo "{"

    grep -v '^[[:space:]]*$' "$ENV_FILE" \
    | grep -v '^[[:space:]]*#' \
    | sed -E 's/\r$//; s/^([A-Za-z_][A-Za-z0-9_]*)="?([^"]*)"?$/  "\1": "\2",/'

    echo "}"
  } > "$JSON_FILE"

  # Remove trailing comma safely
  sed -i '$!N; s/,\n}/\n}/' "$JSON_FILE"

done

echo "✅ All .env files converted successfully"
