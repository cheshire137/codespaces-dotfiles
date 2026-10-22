#!/bin/bash

set -e

[ "${CODESPACES:-}" = "true" ] || exit 0

if [ -z "${CODESPACE_NAME:-}" ]; then
  echo "==> CODESPACE_NAME is missing; cannot pick a stable VS Code color" >&2
  exit 1
fi

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_settings="$dotfiles_dir/vscode/machine-settings.json"

apply_to() {
  local machine_dir="$1"
  local target_settings="$machine_dir/settings.json"

  mkdir -p "$machine_dir"

  if ! command -v python3 >/dev/null 2>&1; then
    echo "==> python3 unavailable; cannot merge $target_settings" >&2
    return 1
  fi

  python3 - "$source_settings" "$target_settings" "$CODESPACE_NAME" <<'PY'
import hashlib
import json
import os
import sys
import tempfile

source_path, target_path, codespace_name = sys.argv[1:]

with open(source_path) as handle:
    incoming = json.load(handle)

try:
    existing = {}
    if os.path.exists(target_path) and os.path.getsize(target_path):
        with open(target_path) as handle:
            existing = json.load(handle)
except (json.JSONDecodeError, OSError) as error:
    print(f"==> Cannot read {target_path}; leaving it untouched: {error}", file=sys.stderr)
    sys.exit(1)

if not isinstance(incoming, dict) or not isinstance(existing, dict):
    print("==> VS Code settings must be JSON objects; leaving existing settings untouched", file=sys.stderr)
    sys.exit(1)

palette = ("#235093", "#6b327c", "#17655f", "#7a3e24", "#704c12", "#7a3045", "#3f527d", "#4b5e28")
color_index = int(hashlib.sha256(codespace_name.encode()).hexdigest(), 16) % len(palette)
color = palette[color_index]
colors = incoming["workbench.colorCustomizations"]
for key in (
    "titleBar.activeBackground",
    "titleBar.inactiveBackground",
    "statusBar.background",
    "activityBar.background",
):
    colors[key] = color

for key, value in incoming.items():
    if isinstance(value, dict) and isinstance(existing.get(key), dict):
        existing[key].update(value)
    else:
        existing[key] = value

temporary_path = None
try:
    with tempfile.NamedTemporaryFile(mode="w", dir=os.path.dirname(target_path), delete=False) as handle:
        temporary_path = handle.name
        json.dump(existing, handle, indent=2)
        handle.write("\n")
    os.replace(temporary_path, target_path)
finally:
    if temporary_path and os.path.exists(temporary_path):
        os.unlink(temporary_path)

print(f"==> Applied VS Code remote settings with color {color} to {target_path}")
PY
}

# The server directory differs between Codespaces images and VS Code builds, so
# cover both rather than guessing which one this codespace uses.
applied=""
for server_root in "$HOME/.vscode-remote" "$HOME/.vscode-server"; do
  if [ -d "$server_root" ]; then
    apply_to "$server_root/data/Machine"
    applied="yes"
  fi
done

if [ -z "$applied" ]; then
  apply_to "$HOME/.vscode-remote/data/Machine"
fi
