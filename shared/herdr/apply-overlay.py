#!/usr/bin/env python3
"""Apply herdr/config.toml extras onto an Omarchy-owned config.toml.

Herdr has no include path. This patches prefix, onboarding, and [[keys.command]]
blocks without replacing Omarchy's tmux-style keybindings.
"""
from __future__ import annotations

import argparse
import re
import tomllib
from pathlib import Path


def set_onboarding(text: str, value: bool) -> str:
    line = f"onboarding = {'true' if value else 'false'}"
    if re.search(r"(?m)^onboarding\s*=", text):
        return re.sub(r"(?m)^onboarding\s*=\s*.*$", line, text, count=1)
    if text.startswith("#"):
        return line + "\n" + text
    return line + "\n" + text


def set_keys_prefix(text: str, prefix: str) -> str:
    match = re.search(r"(?ms)^\[keys\](?:\n(?:[^[\n].*)?)*", text)
    if not match:
        return text.rstrip() + f'\n\n[keys]\nprefix = "{prefix}"\n'
    section = match.group(0)
    if re.search(r"(?m)^prefix\s*=", section):
        section = re.sub(
            r'(?m)^prefix\s*=\s*.*$', f'prefix = "{prefix}"', section, count=1
        )
    else:
        section = re.sub(r"(?m)^\[keys\]\s*$", f'[keys]\nprefix = "{prefix}"', section, count=1)
    return text[: match.start()] + section + text[match.end() :]


def append_commands(text: str, commands: list[dict]) -> str:
    for cmd in commands:
        needle = cmd["command"]
        if needle in text:
            continue
        text = text.rstrip() + (
            "\n\n[[keys.command]]\n"
            f'key = "{cmd["key"]}"\n'
            f'type = "{cmd["type"]}"\n'
            f'command = "{needle}"\n'
            f'description = "{cmd.get("description", "")}"\n'
        )
    return text


def apply(dest: Path, overlay: Path) -> None:
    ov = tomllib.loads(overlay.read_text())
    text = dest.read_text()
    if "onboarding" in ov:
        text = set_onboarding(text, bool(ov["onboarding"]))
    keys = ov.get("keys") or {}
    if "prefix" in keys:
        text = set_keys_prefix(text, str(keys["prefix"]))
    text = append_commands(text, keys.get("command") or [])
    dest.write_text(text)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("dest")
    parser.add_argument("overlay")
    args = parser.parse_args()
    apply(Path(args.dest), Path(args.overlay))


if __name__ == "__main__":
    main()
