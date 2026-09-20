#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ $# -eq 1 ]] || { echo "Usage: $0 /path/to/FlappyBird-PWA" >&2; exit 2; }
"$ROOT/generate-pwa-traces.sh" "$1"
failed=0
for file in "$ROOT"/scenarios/*.json; do
  id="$(basename "$file" .json)"
  apk="$ROOT/traces/apk/$id/latest.csv"
  [[ -f "$apk" ]] || apk="$ROOT/golden/apk/$id.csv"
  pwa="$ROOT/traces/pwa/$id.csv"
  echo "COMPARE $id"
  node "$ROOT/tools/compare-traces.mjs" "$apk" "$pwa" || failed=$((failed + 1))
done
if (( failed > 0 )); then
  echo "$failed scenario(s) divergent(s)." >&2
  exit 1
fi
