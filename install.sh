#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK="$ROOT/out/FlappyBird-1.3-instrumented.apk"
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall-original) UNINSTALL=1; shift ;;
    --apk) APK="$2"; shift 2 ;;
    *) echo "Usage: $0 [--uninstall-original] [--apk path.apk]" >&2; exit 2 ;;
  esac
done

command -v adb >/dev/null 2>&1 || { echo "adb introuvable dans le PATH" >&2; exit 1; }
[[ -f "$APK" ]] || { echo "APK introuvable: $APK" >&2; exit 1; }

adb wait-for-device
if [[ "$UNINSTALL" -eq 1 ]]; then
  adb uninstall com.dotgears.flappybird || true
fi
adb install -r "$APK"
