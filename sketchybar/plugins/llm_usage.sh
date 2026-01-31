#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"

PARENT_ITEM="llm_copilot"
COPILOT_ITEM="llm_copilot"
GEMINI_ITEM="llm_gemini"
CURSOR_ITEM="llm_cursor"

CACHE_TTL="${LLM_CACHE_TTL:-900}"
CODEXBAR_BIN="${CODEXBAR_BIN:-codexbar}"

TOGGLE=0
FORCE_REFRESH=0

for arg in "$@"; do
  case "$arg" in
    --toggle) TOGGLE=1 ;;
    --refresh) FORCE_REFRESH=1 ;;
  esac
done

if [ "$TOGGLE" -eq 1 ]; then
  sketchybar --set "$PARENT_ITEM" popup.drawing=toggle
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

CACHE_DIR="$HOME/.cache/codexbar"
CACHE_FILE="$CACHE_DIR/sketchybar-usage.json"

if ! command -v "$CODEXBAR_BIN" >/dev/null 2>&1; then
  sketchybar --set "$COPILOT_ITEM" label="--"
  sketchybar --set "$GEMINI_ITEM" label="--"
  sketchybar --set "$CURSOR_ITEM" label="--"
  exit 0
fi

refresh=0
if [ "$FORCE_REFRESH" -eq 1 ]; then
  refresh=1
elif [ ! -f "$CACHE_FILE" ]; then
  refresh=1
else
  now=$(date +%s)
  mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
  age=$((now - mtime))
  if [ "$age" -ge "$CACHE_TTL" ]; then
    refresh=1
  fi
fi

if [ "$refresh" -eq 1 ]; then
  mkdir -p "$CACHE_DIR"
  COPILOT_JSON="$($CODEXBAR_BIN --provider copilot --format json --json-only 2>/dev/null || true)"
  GEMINI_JSON="$($CODEXBAR_BIN --provider gemini --format json --json-only 2>/dev/null || true)"
  CURSOR_JSON="$($CODEXBAR_BIN --provider cursor --format json --json-only 2>/dev/null || true)"
  CACHE_FILE="$CACHE_FILE" \
  COPILOT_JSON="$COPILOT_JSON" GEMINI_JSON="$GEMINI_JSON" CURSOR_JSON="$CURSOR_JSON" \
  python3 - <<'PY'
import json
import os
import time

def decode(raw: str):
    if not raw:
        return None
    try:
        data = json.loads(raw)
    except Exception:
        return None
    if isinstance(data, list):
        return data[0] if data else None
    if isinstance(data, dict):
        return data
    return None

payload = {
    "updatedAt": int(time.time()),
    "providers": {
        "copilot": decode(os.environ.get("COPILOT_JSON", "")),
        "gemini": decode(os.environ.get("GEMINI_JSON", "")),
        "cursor": decode(os.environ.get("CURSOR_JSON", "")),
    },
}

path = os.environ.get("CACHE_FILE")
if path:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f)
PY
fi

CACHE_FILE="$CACHE_FILE" \
python3 - <<'PY' | while IFS=$'\t' read -r name percent; do
import json
import os

cache_file = os.environ.get("CACHE_FILE", "")
providers = {}
try:
    with open(cache_file, "r", encoding="utf-8") as f:
        data = json.load(f)
        providers = data.get("providers", {}) if isinstance(data, dict) else {}
except Exception:
    providers = {}

def used_percent(payload):
    if not payload:
        return None
    usage = payload.get("usage") or {}
    primary = usage.get("primary") or {}
    used = primary.get("usedPercent")
    if used is None:
        remaining = primary.get("remainingPercent")
        if remaining is not None:
            used = 100 - remaining
    return used

for name in ("copilot", "gemini", "cursor"):
    used = used_percent(providers.get(name))
    percent = "" if used is None else str(int(round(float(used))))
    print(f"{name}\t{percent}")
PY
  case "$name" in
    copilot) item="$COPILOT_ITEM" ;;
    gemini) item="$GEMINI_ITEM" ;;
    cursor) item="$CURSOR_ITEM" ;;
    *) continue ;;
  esac

  if [ -z "$percent" ]; then
    sketchybar --set "$item" label="--"
  else
    sketchybar --set "$item" label="${percent}%"
  fi
done
