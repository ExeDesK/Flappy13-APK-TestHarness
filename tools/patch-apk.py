#!/usr/bin/env python3
"""Patch a decoded Flappy Bird 1.3 APK with the deterministic test harness.

This tool does not contain or download the game APK. It only modifies an APK
that the user supplies locally after apktool has decoded it.
"""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8", newline="\n")


def smali_roots(decoded: Path) -> list[Path]:
    roots = sorted(p for p in decoded.iterdir() if p.is_dir() and p.name.startswith("smali"))
    if not roots:
        raise RuntimeError(f"No smali* directory found under {decoded}")
    return roots


def find_smali(decoded: Path, relative: str) -> tuple[Path, Path]:
    rel = Path(*relative.split("/"))
    for root in smali_roots(decoded):
        candidate = root / rel
        if candidate.is_file():
            return candidate, root
    raise RuntimeError(f"Smali file not found: {relative}")


def patch_splash(path: Path) -> None:
    text = read_text(path)
    hook = "TestHarness;->init(Landroid/app/Activity;)V"
    if hook in text:
        print("SplashScreen already patched")
        return

    pattern = re.compile(
        r"(\.method protected onCreate\(Landroid/os/Bundle;\)V.*?^\s*"
        r"invoke-super \{p0, p1\}, Landroid/app/Activity;->onCreate\(Landroid/os/Bundle;\)V\s*$)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    if not match:
        raise RuntimeError("Could not locate SplashScreen.onCreate insertion point")

    replacement = (
        match.group(1)
        + "\n\n    invoke-static {p0}, "
        + "Lcom/dotgears/flappy/TestHarness;->init(Landroid/app/Activity;)V"
    )
    text = text[: match.start()] + replacement + text[match.end() :]
    write_text(path, text)


def patch_seed(path: Path) -> None:
    text = read_text(path)
    if "TestHarness;->seed(I)I" in text:
        print("RNG seed already patched")
        return

    lines = text.splitlines()
    try:
        current = next(i for i, line in enumerate(lines) if "Ljava/lang/System;->currentTimeMillis()J" in line)
    except StopIteration as exc:
        raise RuntimeError("System.currentTimeMillis() not found in com.dotgears.c") from exc

    long_to_int = -1
    seed_call = -1
    reg: str | None = None
    for i in range(current, min(current + 12, len(lines))):
        m = re.match(r"^\s*long-to-int\s+([vp]\d+),", lines[i])
        if m:
            long_to_int = i
            reg = m.group(1)
        if "Lcom/dotgears/j;->a(I)V" in lines[i]:
            seed_call = i
            break

    if long_to_int < 0 or seed_call < 0 or reg is None:
        raise RuntimeError("Unrecognized RNG seed sequence")

    lines.insert(seed_call, f"    invoke-static {{{reg}}}, Lcom/dotgears/flappy/TestHarness;->seed(I)I")
    lines.insert(seed_call + 1, f"    move-result {reg}")
    write_text(path, "\n".join(lines) + "\n")


def patch_tick(path: Path) -> None:
    text = read_text(path)
    if "TestHarness;->beforeTick(Lcom/dotgears/flappy/c;)V" in text:
        print("Tick hooks already patched")
        return

    start_match = re.search(r"(?m)^\.method public b\(F\)V\s*$", text)
    if not start_match:
        raise RuntimeError("Method flappy.c.b(F)V not found")

    end_index = text.find(".end method", start_match.start())
    if end_index < 0:
        raise RuntimeError("End of flappy.c.b(F)V not found")
    end_index += len(".end method")

    before = text[: start_match.start()]
    method = text[start_match.start() : end_index]
    after = text[end_index:]

    method, count = re.subn(
        r"(?m)^(\s*\.(?:locals|registers)\s+\d+\s*)$",
        r"\1\n\n    invoke-static {p0}, Lcom/dotgears/flappy/TestHarness;->beforeTick(Lcom/dotgears/flappy/c;)V",
        method,
        count=1,
    )
    if count != 1:
        raise RuntimeError("Could not insert beforeTick hook")

    method, count = re.subn(
        r"(?m)^(\s*)return-void\s*$",
        r"\1invoke-static {p0}, Lcom/dotgears/flappy/TestHarness;->afterTick(Lcom/dotgears/flappy/c;)V\n\1return-void",
        method,
    )
    if count == 0:
        raise RuntimeError("Could not insert afterTick hook")

    write_text(path, before + method + after)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--decoded", required=True, type=Path)
    parser.add_argument("--patch", required=True, type=Path)
    args = parser.parse_args()

    decoded = args.decoded.resolve()
    patch = args.patch.resolve()
    if not decoded.is_dir():
        raise SystemExit(f"Decoded APK directory not found: {decoded}")
    if not patch.is_file():
        raise SystemExit(f"Harness patch not found: {patch}")

    splash, _ = find_smali(decoded, "com/dotgears/flappy/SplashScreen.smali")
    scene_bridge, _ = find_smali(decoded, "com/dotgears/c.smali")
    game, game_root = find_smali(decoded, "com/dotgears/flappy/c.smali")

    harness_dest = game_root / "com" / "dotgears" / "flappy" / "TestHarness.smali"
    harness_dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(patch, harness_dest)

    patch_splash(splash)
    patch_seed(scene_bridge)
    patch_tick(game)

    print(f"Patched decoded APK: {decoded}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
