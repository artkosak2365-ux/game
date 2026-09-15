#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/build/macos/game.zip"
mkdir -p "$(dirname "$OUT")"
godot --headless --path "$ROOT" --import --quit
godot --headless --path "$ROOT" --export-release "macOS" "$OUT"
test -f "$OUT"
echo "Exported $OUT ($(stat -c%s "$OUT") bytes)"
echo "Note: macOS builds from Linux are unsigned. Sign/notarize later on a Mac."
