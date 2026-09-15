#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== versions =="
godot --version
gdlint --version
openspec --version
python3 --version
node --version

echo "== gdscript lint =="
gdlint "$ROOT/scripts"

echo "== import + headless smoke =="
godot --headless --path "$ROOT" --import --quit
godot --headless --path "$ROOT" --script "$ROOT/tools/smoke_test.gd"

echo "== windows export templates =="
test -f "${HOME}/.local/share/godot/export_templates/4.7.2.stable/windows_release_x86_64.exe"
test -f "${HOME}/.local/share/godot/export_templates/4.7.2.stable/macos.zip"

echo "SMOKE_OK"
