#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ $# -eq 1 ]] || { echo "Usage: $0 /path/to/FlappyBird-PWA" >&2; exit 2; }
node "$ROOT/tools/generate-pwa-traces.mjs" "$1" "$ROOT"
