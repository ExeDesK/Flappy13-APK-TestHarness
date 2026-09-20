#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'Flappy Bird 1.3 - cross-test suite'
echo 'Chaque scenario relance l APK. Au menu, clique UNE FOIS sur PLAY puis ne touche plus.'
echo

for file in "$ROOT"/scenarios/*.json; do
  id="$(basename "$file" .json)"
  title="$(node -e "const fs=require('fs');const s=JSON.parse(fs.readFileSync(process.argv[1],'utf8'));console.log(s.title)" "$file")"
  echo "Prochain scenario : $id - $title"
  read -r -p 'Appuie sur Entree pour lancer'
  "$ROOT/run-scenario.sh" "$id"
done

echo
echo 'Suite APK terminee. Traces archivees sous traces/apk/<scenario>/.'
