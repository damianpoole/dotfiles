#!/usr/bin/env bash
# Stow shared + macOS packages. Re-run after git pull.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${HOME}/.config"
SHARED="${ROOT}/shared"
MACOS="${ROOT}/macos"

cd "$ROOT"

stow -v -d "$SHARED" -t "$TARGET" .
stow -v -d "$MACOS" -t "$TARGET" .
# zshrc/.zshrc lives under $HOME, not ~/.config
stow -v -d "$MACOS" -t "$HOME" zshrc

echo "Stowed shared/ and macos/ (zshrc -> \$HOME)"
