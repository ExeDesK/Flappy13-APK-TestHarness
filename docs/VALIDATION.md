# Validation contract

This harness exists to answer one narrow question: **does the reimplementation produce the same deterministic simulation state as the reference APK for the same seed and input ticks?**

## What is compared

The canonical suite covers four runs:

| Scenario | Purpose | Expected terminal state |
|---|---|---|
| `01-ground` | launch then no correction | ground, tick 53, score 0 |
| `02-score10` | pass 10 pipes | lower pipe, tick 953, score 10 |
| `03-sky-pipe` | repeated climb | upper pipe, tick 224, score 0 |
| `04-long20` | longer run | lower pipe, tick 1733, score 20 |

The comparison checks every recorded field for every state row. Physics floats are compared as float32 bit patterns.

## Golden traces

`golden/apk/*.csv` are the canonical APK traces. `golden/manifest.json` records their SHA-256 hashes and terminal metadata.

Run:

```bash
npm test
```

to verify their integrity and validate them against the scenario definitions.

## Scope of a 1:1 claim

A zero-difference result is strong evidence that the tested deterministic state path matches the reference APK. It does not by itself prove every visual, audio, timing, lifecycle or platform behavior of the complete application. Those require separate tests.
