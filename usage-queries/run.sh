#!/usr/bin/env bash
# Runs every *.sql in this directory against ~/.config/nvim/usage/*.jsonl
# via DuckDB. Outputs date-stamped markdown reports to results/<YYYY-MM-DD>/.
#
# Usage:
#   ./run.sh                  # run every *.sql
#   ./run.sh 01-top-mappings  # run a single query by name (with or without .sql)

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
cd "$CONFIG_DIR"

if ! command -v duckdb >/dev/null 2>&1; then
  echo "duckdb not found in PATH" >&2
  exit 1
fi

shopt -s nullglob
logs=(usage/*.jsonl)
if [ ${#logs[@]} -eq 0 ]; then
  echo "No JSONL logs in $CONFIG_DIR/usage/" >&2
  exit 1
fi

TODAY=$(date +%Y-%m-%d)
OUT_DIR="$SCRIPT_DIR/results/$TODAY"
mkdir -p "$OUT_DIR"

if [ $# -gt 0 ]; then
  arg="${1%.sql}"
  queries=("$SCRIPT_DIR/${arg}.sql")
else
  queries=("$SCRIPT_DIR"/*.sql)
fi

passed=0
failed=0
for sql in "${queries[@]}"; do
  [ -f "$sql" ] || { echo "Missing: $sql" >&2; failed=$((failed+1)); continue; }
  name=$(basename "$sql" .sql)
  out="$OUT_DIR/$name.md"
  err="$out.err"

  {
    echo "# $name"
    echo
    echo "_Generated: $(date '+%Y-%m-%d %H:%M:%S')_"
    echo
    echo "## Query"
    echo
    echo '```sql'
    cat "$sql"
    echo '```'
    echo
    echo "## Result"
    echo
  } > "$out"

  if duckdb -markdown -c "$(cat "$sql")" >> "$out" 2>"$err"; then
    rm -f "$err"
    echo "  [ok]   $name"
    passed=$((passed+1))
  else
    {
      echo
      echo "## Error"
      echo
      echo '```'
      cat "$err"
      echo '```'
    } >> "$out"
    rm -f "$err"
    echo "  [fail] $name -> $out" >&2
    failed=$((failed+1))
  fi
done

echo
echo "$passed passed, $failed failed -> $OUT_DIR"
