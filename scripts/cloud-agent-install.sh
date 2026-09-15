#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the Godot strategy-game toolchain.
# Safe to re-run. Does not start servers.
set -euo pipefail

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
fi
export PATH="${HOME}/.nvm/versions/node/v22.22.2/bin:${HOME}/.local/bin:${PATH}"

GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_TAG="${GODOT_TAG:-${GODOT_VERSION}-stable}"
GODOT_DIR="${HOME}/.local/opt/godot"
GODOT_BIN="${HOME}/.local/bin/godot"
TEMPLATES_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
VENV_DIR="${HOME}/.local/share/game-dev/venv"
DOWNLOAD_DIR="${HOME}/.cache/game-dev/downloads"
RELEASE_BASE="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}"

mkdir -p "$GODOT_DIR" "$(dirname "$GODOT_BIN")" "$DOWNLOAD_DIR" "${HOME}/.local/share/game-dev"

need_godot=0
if [[ ! -x "$GODOT_BIN" ]]; then
  need_godot=1
elif ! "$GODOT_BIN" --version 2>/dev/null | grep -q "${GODOT_VERSION}"; then
  need_godot=1
fi

if [[ "$need_godot" -eq 1 ]]; then
  zip_path="${DOWNLOAD_DIR}/Godot_v${GODOT_TAG}_linux.x86_64.zip"
  curl -L --fail --retry 5 --retry-delay 2 -o "$zip_path" \
    "${RELEASE_BASE}/Godot_v${GODOT_TAG}_linux.x86_64.zip"
  extract_dir="$(mktemp -d)"
  unzip -o "$zip_path" -d "$extract_dir"
  bin="$(find "$extract_dir" -type f -name 'Godot*' | head -1)"
  install -m 0755 "$bin" "${GODOT_DIR}/godot"
  ln -sfn "${GODOT_DIR}/godot" "$GODOT_BIN"
  rm -rf "$extract_dir"
fi

if [[ ! -f "${TEMPLATES_DIR}/windows_release_x86_64.exe" || ! -f "${TEMPLATES_DIR}/macos.zip" ]]; then
  tpz_path="${DOWNLOAD_DIR}/Godot_v${GODOT_TAG}_export_templates.tpz"
  curl -L --fail --retry 5 --retry-delay 2 -o "$tpz_path" \
    "${RELEASE_BASE}/Godot_v${GODOT_TAG}_export_templates.tpz"
  extract_dir="$(mktemp -d)"
  python3 - "$tpz_path" "$extract_dir" <<'PY'
import sys, zipfile
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
PY
  mkdir -p "$TEMPLATES_DIR"
  cp -a "${extract_dir}/templates/." "$TEMPLATES_DIR/"
  echo "${GODOT_VERSION}.stable" > "${TEMPLATES_DIR}/version.txt"
  rm -rf "$extract_dir"
fi

if [[ ! -x "${VENV_DIR}/bin/gdlint" ]]; then
  python3 -m venv "$VENV_DIR"
  "${VENV_DIR}/bin/pip" install --upgrade pip gdtoolkit
fi
ln -sfn "${VENV_DIR}/bin/gdlint" "${HOME}/.local/bin/gdlint"
ln -sfn "${VENV_DIR}/bin/gdformat" "${HOME}/.local/bin/gdformat"
ln -sfn "${VENV_DIR}/bin/gdparse" "${HOME}/.local/bin/gdparse"

if ! command -v openspec >/dev/null 2>&1; then
  npm install -g @fission-ai/openspec@latest
fi
if [[ -n "$(command -v openspec)" ]]; then
  ln -sfn "$(command -v openspec)" "${HOME}/.local/bin/openspec"
fi
if [[ -n "$(command -v node)" ]]; then
  ln -sfn "$(command -v node)" "${HOME}/.local/bin/node"
fi
if [[ -n "$(command -v npm)" ]]; then
  ln -sfn "$(command -v npm)" "${HOME}/.local/bin/npm"
fi

if [[ ! -d "${HOME}/.cursor/skills/gsd-new-project" ]]; then
  npx --yes @opengsd/gsd-core@latest --cursor --global --no-legacy-cleanup
fi

echo "godot=$("$GODOT_BIN" --version)"
echo "gdlint=$(gdlint --version)"
echo "openspec=$(openspec --version)"
test -f "${TEMPLATES_DIR}/windows_release_x86_64.exe"
test -f "${TEMPLATES_DIR}/macos.zip"

ROOT="${CLOUD_AGENT_WORKSPACE:-/workspace}"
if [[ -f "${ROOT}/project.godot" ]]; then
  mkdir -p "${ROOT}/build/windows" "${ROOT}/build/macos" "${ROOT}/build/linux"
  "$GODOT_BIN" --headless --path "$ROOT" --import --quit
fi
