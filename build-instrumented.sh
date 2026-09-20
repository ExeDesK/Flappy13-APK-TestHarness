#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPECTED_APK_SHA="a3e6958ce2100966f4e207778e4cdbe72788214148c7f4bfd042ba365498deb3"
EXPECTED_APKTOOL_SHA="7956eb04194300ce0d0a84ad18771eebc94b89fb8d1ddcce8ea4c056818646f4"
APKTOOL="$ROOT/.cache/apktool_2.9.3.jar"
OUT="$ROOT/out/FlappyBird-1.3-instrumented.apk"
ALLOW_UNVERIFIED=0

usage() {
  echo "Usage: $0 [--allow-unverified-apk] <FlappyBird-1.3.apk> [output.apk]"
}

if [[ "${1:-}" == "--allow-unverified-apk" ]]; then
  ALLOW_UNVERIFIED=1
  shift
fi
[[ $# -ge 1 && $# -le 2 ]] || { usage; exit 2; }
APK="$1"
[[ $# -eq 2 ]] && OUT="$2"
[[ -f "$APK" ]] || { echo "APK introuvable: $APK" >&2; exit 1; }

for cmd in java keytool jarsigner python3 sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "$cmd introuvable dans le PATH" >&2; exit 1; }
done

actual_apk="$(sha256sum "$APK" | awk '{print $1}')"
if [[ "$actual_apk" != "$EXPECTED_APK_SHA" ]]; then
  if [[ "$ALLOW_UNVERIFIED" -ne 1 ]]; then
    echo "APK non reconnu." >&2
    echo "SHA-256: $actual_apk" >&2
    echo "Attendu : $EXPECTED_APK_SHA" >&2
    echo "Utilise --allow-unverified-apk uniquement pour un test volontaire." >&2
    exit 1
  fi
  echo "WARNING: APK non verifie: $actual_apk" >&2
else
  echo "APK 1.3 de reference verifie: $actual_apk"
fi

mkdir -p "$ROOT/.cache" "$(dirname "$OUT")"
if [[ ! -f "$APKTOOL" ]]; then
  url="https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar"
  echo "Telechargement apktool 2.9.3..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$APKTOOL"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$APKTOOL" "$url"
  else
    echo "curl ou wget requis pour telecharger apktool" >&2
    exit 1
  fi
fi

actual_apktool="$(sha256sum "$APKTOOL" | awk '{print $1}')"
[[ "$actual_apktool" == "$EXPECTED_APKTOOL_SHA" ]] || {
  echo "SHA-256 apktool invalide: $actual_apktool" >&2
  exit 1
}

WORK="$ROOT/work"
DECODED="$WORK/decoded"
rm -rf "$WORK"
mkdir -p "$DECODED"

echo "Decodage APK..."
java -jar "$APKTOOL" d -f "$APK" -o "$DECODED"

echo "Injection du harness..."
python3 "$ROOT/tools/patch-apk.py" --decoded "$DECODED" --patch "$ROOT/patches/TestHarness.smali"

UNSIGNED="$WORK/FlappyBird-1.3-instrumented-unsigned.apk"
echo "Recompilation APK..."
java -jar "$APKTOOL" b "$DECODED" -o "$UNSIGNED"

KEYSTORE="$ROOT/.cache/flappy13-test.jks"
if [[ ! -f "$KEYSTORE" ]]; then
  echo "Creation de la cle de test locale..."
  keytool -genkeypair -v -keystore "$KEYSTORE" -storepass flappy13test -keypass flappy13test \
    -alias flappy13test -keyalg RSA -keysize 2048 -validity 3650 \
    -dname 'CN=Flappy13 Test Harness,O=Local Test,C=FR'
fi

cp "$UNSIGNED" "$OUT"
echo "Signature APK de test..."
jarsigner -keystore "$KEYSTORE" -storepass flappy13test -keypass flappy13test \
  -sigalg SHA256withRSA -digestalg SHA-256 "$OUT" flappy13test >/dev/null
jarsigner -verify "$OUT" >/dev/null

echo
echo "APK instrumentee prete: $OUT"
echo "La signature est differente de l APK original: desinstalle l original avant installation."
