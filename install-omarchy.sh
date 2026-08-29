#!/usr/bin/env bash
# Fold shared/ (and Omarchy-only extras) into an existing Omarchy ~/.config.
# Re-run after git pull. Do not use install-macos.sh on this machine.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${HOME}/.config"
NVIM_TARGET="${TARGET}/nvim"
SHARED="${ROOT}/shared"

cd "$ROOT"

adopt_for_stow() {
  local dest="$1"
  if [[ -e $dest && ! -L $dest ]]; then
    mv "$dest" "${dest}.bak.omarchy"
    echo "Moved $dest aside (now owned by this repo)."
  fi
}

# Herdr has no include. Keep Omarchy's config.toml; patch with shared/herdr/config.toml.
apply_herdr_overlay() {
  local dest="${TARGET}/herdr/config.toml"
  local stock="${OMARCHY_PATH:-/usr/share/omarchy}/config/herdr/config.toml"
  local overlay="${SHARED}/herdr/config.toml"

  mkdir -p "$(dirname "$dest")"
  if [[ -L $dest ]]; then
    rm -f "$dest"
  fi
  if [[ ! -f $dest ]]; then
    cp -f "$stock" "$dest"
    echo "Restored Omarchy herdr config to $dest"
  fi
  python3 "${SHARED}/herdr/apply-overlay.py" "$dest" "$overlay"
  echo "Applied herdr overlay from $overlay"
}

ensure_bashrc_source() {
  local bashrc="${HOME}/.bashrc"
  local line="[[ -r ${ROOT}/omarchy/bashrc ]] && source ${ROOT}/omarchy/bashrc"
  if [[ -f $bashrc ]] && ! grep -qF 'omarchy/bashrc' "$bashrc"; then
    printf '\n%s\n' "$line" >>"$bashrc"
    echo "Sourced omarchy/bashrc from $bashrc"
  fi
}

# Early options: Omarchy's options.lua must require the shared module.
ensure_nvim_options() {
  local options_lua="${NVIM_TARGET}/lua/config/options.lua"
  local options_require='require("config.user-options")'
  if [[ -f $options_lua ]] && ! grep -qF "$options_require" "$options_lua"; then
    printf '\n%s\n' "$options_require" >>"$options_lua"
    echo "Sourced $options_require from $options_lua"
  fi
}

adopt_for_stow "${NVIM_TARGET}/lazyvim.json"
apply_herdr_overlay
ensure_nvim_options
ensure_bashrc_source

# shared/ only contains unique filenames, so no nvim clash ignores are needed.
# Skip herdr (overlay above) and the apply helper.
stow -v \
  --ignore='herdr/config.toml' \
  --ignore='apply-overlay.py' \
  -d "$SHARED" -t "$TARGET" .

echo "Stowed $SHARED onto $TARGET"
if command -v herdr >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 || true
fi
