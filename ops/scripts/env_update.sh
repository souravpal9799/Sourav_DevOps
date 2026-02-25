#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${1:-}"

if [[ -z "$BASE_DIR" || ! -d "$BASE_DIR" ]]; then
  echo "Usage: $0 /path/to/directory"
  exit 1
fi

echo "📂 Scanning directory: $BASE_DIR"
echo

find "$BASE_DIR" -type f -name ".env" ! -name "*.j2" ! -name "*.json" | while read -r ENV_FILE; do

  JSON_FILE="${ENV_FILE}.json"
  JINJA_FILE="${ENV_FILE}.j2"

  echo "🔄 Processing $ENV_FILE"
  echo "   → $JSON_FILE"
  echo "   → $JINJA_FILE"

  ########################################
  # JSON output
  ########################################
  {
    echo "{"

    grep -v '^[[:space:]]*$' "$ENV_FILE" \
    | grep -v '^[[:space:]]*#' \
    | sed -E '
        s/\r$//;
        s/^([A-Za-z_][A-Za-z0-9_]*)="?([^"]*)"?$/  "\1": "\2",/
      '

    echo "}"
  } > "$JSON_FILE"

  sed -i ':a;N;$!ba;s/,\n}/\n}/' "$JSON_FILE"

  ########################################
  # Jinja output
  ########################################
  sed -E '
    s/\r$//;
    /^[[:space:]]*#/b;
    /^[[:space:]]*$/b;
    s/^([A-Za-z_][A-Za-z0-9_]*)=.*/\1={{\1}}/
  ' "$ENV_FILE" > "$JINJA_FILE"

  echo
done

echo "✅ All env files processed"
