#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ $# -eq 1 ]] || { echo "Usage: $0 <scenario-id>" >&2; exit 2; }
NAME="$1"
SCENARIO="$ROOT/scenarios/$NAME.json"
[[ -f "$SCENARIO" ]] || { echo "Scenario introuvable: $NAME" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "node introuvable dans le PATH" >&2; exit 1; }

readarray -t META < <(node - "$SCENARIO" <<'JS'
const fs = require('fs');
const s = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
console.log(s.id);
console.log(s.title);
console.log(s.seed);
console.log(s.taps.join(','));
console.log(s.expected.score);
console.log(s.expected.endTick);
console.log(s.expected.death);
JS
)
ID="${META[0]}"; TITLE="${META[1]}"; SEED="${META[2]}"; TAPS="${META[3]}"
SCORE="${META[4]}"; END_TICK="${META[5]}"; DEATH="${META[6]}"
DIR="$ROOT/traces/apk/$ID"
mkdir -p "$DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$DIR/$STAMP.csv"

echo
echo "=== $ID : $TITLE ==="
echo "Seed : $SEED"
echo "Score attendu : $SCORE"
echo "Fin attendue : tick $END_TICK, $DEATH"
echo

"$ROOT/run-replay.sh" --seed "$SEED" --taps "$TAPS" --out "$OUT"
cp "$OUT" "$DIR/latest.csv"
node "$ROOT/tools/validate-trace.mjs" "$SCENARIO" "$OUT"
echo
echo "Archive : $OUT"
echo "Latest  : $DIR/latest.csv"
