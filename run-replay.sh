#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED=123456789
TAPS='0,18,36,54,72,90,108,126,144,162,180'
OUT="$ROOT/out/apk-trace.csv"
TIMEOUT=600

usage() {
  echo "Usage: $0 [--seed N] [--taps 0,18,...] [--out trace.csv] [--timeout seconds]"
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed) SEED="$2"; shift 2 ;;
    --taps) TAPS="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    *) usage; exit 2 ;;
  esac
done

command -v adb >/dev/null 2>&1 || { echo "adb introuvable dans le PATH" >&2; exit 1; }
mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
TMP="$(mktemp)"
LOGCAT_PID=''
cleanup() {
  if [[ -n "$LOGCAT_PID" ]]; then kill "$LOGCAT_PID" 2>/dev/null || true; fi
  rm -f "$TMP"
}
trap cleanup EXIT INT TERM

adb wait-for-device
adb logcat -c
adb shell am force-stop com.dotgears.flappybird
adb logcat -v raw -s Flappy13Trace:I '*:S' >"$TMP" 2>/dev/null &
LOGCAT_PID=$!
sleep 0.25

printf 'Seed : %s\nTaps : %s\n' "$SEED" "$TAPS"
adb shell am start -S -n com.dotgears.flappybird/com.dotgears.flappy.SplashScreen \
  --ez flappy_test true --ei flappy_seed "$SEED" --es flappy_taps "$TAPS" >/dev/null

echo
echo 'Dans le jeu : appuie UNE FOIS sur PLAY, puis ne touche plus l ecran.'
echo 'Le replay demarre automatiquement quand GET READY est stabilise.'
echo "Trace : $OUT"
echo

TAP_COUNT=0
if [[ -n "$TAPS" ]]; then TAP_COUNT="$(awk -F',' '{print NF}' <<<"$TAPS")"; fi
EXPECTED_CONFIG="CONFIG,seed=$SEED,taps=$TAP_COUNT"

start=$SECONDS
while ! awk -v cfg="$EXPECTED_CONFIG" 'BEGIN{active=0; found=0} $0==cfg{active=1} active && /^END,/{found=1} END{exit(found?0:1)}' "$TMP" 2>/dev/null; do
  if (( SECONDS - start > TIMEOUT )); then
    echo "Timeout apres ${TIMEOUT}s sans END." >&2
    exit 1
  fi
  sleep 0.2
done

kill "$LOGCAT_PID" 2>/dev/null || true
wait "$LOGCAT_PID" 2>/dev/null || true
LOGCAT_PID=''

awk -v cfg="$EXPECTED_CONFIG" 'BEGIN{active=0} $0==cfg{active=1} active{print} active && /^END,/{exit}' "$TMP" > "$OUT"
cat "$OUT"
echo
echo 'Run termine. Trace capturee.'
