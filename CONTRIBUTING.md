# Contributing

Before committing:

```bash
npm test
```

On Linux, also check:

```bash
bash -n ./*.sh
python3 -m py_compile tools/patch-apk.py
```

Do not commit:

- APK/AAB files;
- extracted game assets or native libraries;
- generated instrumented APKs;
- local signing keys/keystores;
- downloaded apktool JARs;
- runtime traces under `traces/`.

Canonical traces belong only under `golden/apk/` and must be accompanied by an updated `golden/manifest.json`.

Scenario changes should be deliberate: changing a seed or input list changes the deterministic contract and therefore requires new APK captures and re-validation against the PWA.
