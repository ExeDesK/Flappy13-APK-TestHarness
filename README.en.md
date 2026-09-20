# Flappy Bird 1.3 — APK Test Harness

[Version française](README.md)

Deterministic test harness used to compare a **locally supplied Android 1.3 APK** with a PWA reimplementation tick by tick.

> This repository contains **no APK**, game artwork, audio, native game library, or signing key. It only contains test instrumentation, automation scripts, and numeric reference traces.

## Reference

```text
APK: Flappy Bird 1.3
SHA-256: A3E6958CE2100966F4E207778E4CDBE72788214148C7F4BFD042BA365498DEB3
Android: 4.4.2
API: 19
ABI: x86
```

Tick convention:

```text
input for tick N
→ simulate tick N
→ S,N = state after tick N
```

## Canonical suite

| Scenario | Goal | Expected terminal state |
|---|---|---|
| `01-ground` | launch then fall | ground, tick 53, score 0 |
| `02-score10` | pass 10 pipes | lower pipe, tick 953, score 10 |
| `03-sky-pipe` | repeated climb | upper pipe, tick 224, score 0 |
| `04-long20` | longer run | lower pipe, tick 1733, score 20 |

The four canonical APK traces are versioned under `golden/apk/` and protected by hashes stored in `golden/manifest.json`.

## Requirements

To **build** the instrumented APK:

- Java / JDK (`java`, `keytool`, `jarsigner`);
- Python 3;
  - on Windows, the script detects `python`, `py -3`, or `python3` and ignores non-working Microsoft Store App Execution Alias stubs;
- Internet access on first build to download apktool 2.9.3.

To **run** the tests:

- Android SDK Platform Tools (`adb`);
- Android 4.4.2 / API 19 / x86 emulator;
- Node.js 18+ for trace validation and PWA comparison.

The build scripts verify the supplied APK SHA-256 by default.

## Windows

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build-instrumented.ps1 -Apk .\FlappyBird-1.3.apk
.\install.ps1 -UninstallOriginal
.\run-suite.ps1
```

At each scenario, click **PLAY exactly once** when the menu appears, then do not touch the screen.

## Linux

```bash
chmod +x *.sh
./build-instrumented.sh ./FlappyBird-1.3.apk
./install.sh --uninstall-original
./run-suite.sh
```

## Run one scenario

Windows:

```powershell
.\run-scenario.ps1 -Name 03-sky-pipe
```

Linux:

```bash
./run-scenario.sh 03-sky-pipe
```

Local captures are written under `traces/apk/<scenario>/`. That directory is ignored by Git.

## Compare with the PWA

The PWA repository is expected to contain `site/src/game.js`.

Windows:

```powershell
.\compare-suite.ps1 -PwaRepo C:\dev\FlappyBird-PWA
```

Linux:

```bash
./compare-suite.sh /home/user/dev/FlappyBird-PWA
```

The comparator regenerates PWA traces and checks every recorded state field. Physics float values are compared by their float32 bit patterns.

## Verify golden traces

No npm dependency install is required:

```bash
npm test
```

This checks hashes and scenario terminal metadata for all canonical APK traces.

## Documentation

- [Reference environment](docs/REFERENCE_ENVIRONMENT.md)
- [Trace format](docs/TRACE_FORMAT.md)
- [Validation contract](docs/VALIDATION.md)

## Project note

Unofficial reverse-engineering, compatibility-testing and deterministic-validation utility. The original application is not distributed by this repository.

> Golden traces are versioned with **LF** line endings so their SHA-256 values stay identical on Windows, Linux and GitHub Actions.
