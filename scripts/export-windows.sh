#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/build/windows/game.exe"
mkdir -p "$(dirname "$OUT")"
godot --headless --path "$ROOT" --import --quit
godot --headless --path "$ROOT" --export-release "Windows Desktop" "$OUT"
test -f "$OUT"
echo "Exported $OUT ($(stat -c%s "$OUT") bytes)"
