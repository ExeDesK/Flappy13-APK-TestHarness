# Changelog

## 3.2.1

- Fixed Windows Python detection: `python3.exe` from the Microsoft Store App Execution Alias is no longer accepted unless it can actually execute Python 3.
- Windows resolution order is now `python`, `py -3`, then `python3`, with an execution check for every candidate.

## 3.2.0

- Clean GitHub-ready repository layout.
- No APK, game assets, generated APK, keystore, or downloaded apktool binary included.
- Windows PowerShell and Linux Bash wrappers for build, install, replay, scenarios, suite and PWA comparison.
- Shared cross-platform APK patcher in Python.
- Strict reference APK SHA-256 verification by default.
- Four canonical APK golden traces retained with SHA-256 manifest.
- Golden trace integrity and scenario validation scripts.
- GitHub Actions CI for golden traces and script syntax.
- Documentation for the reference emulator, trace format and validation contract.

## 3.1

- Treat `CONFIG` as the authoritative start of a run to ignore stale tagged logcat lines.

## 3.0

- Added canonical scenario suite and trace archiving.

## 2.0

- Input injection moved to neutral game coordinate `(144,256)` to avoid the hidden pause hitbox.
