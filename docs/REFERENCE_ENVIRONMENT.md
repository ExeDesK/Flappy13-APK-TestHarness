# Reference environment

The canonical traces in this repository were captured with:

```text
Android: 4.4.2
API:     19
ABI:     x86
```

The reference APK SHA-256 is:

```text
A3E6958CE2100966F4E207778E4CDBE72788214148C7F4BFD042BA365498DEB3
```

The repository does **not** include the APK. The build scripts require the user to provide it locally and verify this hash before patching.

## Suggested AVD

A simple API 19 / x86 AOSP image is sufficient. Google APIs and Play Store are not required.

Useful checks:

```bash
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.product.cpu.abi
```

Expected values:

```text
4.4.2
19
x86
```

## EGL / graphics note

Recent Android Emulator builds can fail to start this old AndEngine application with:

```text
java.lang.IllegalArgumentException: EGLCONFIG_FALLBACK failed!
```

If that happens, use software rendering for the AVD and perform a cold boot. Depending on emulator version, a command-line equivalent can be:

```bash
emulator -avd Flappy13_API19 -gpu swiftshader_indirect -no-snapshot-load
```

Use `emulator -help-gpu` if that backend name is not available in your installed emulator version.
