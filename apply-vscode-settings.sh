#!/bin/bash

set -e

[ "${CODESPACES:-}" = "true" ] || exit 0

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_settings="$dotfiles_dir/vscode/machine-settings.json"

apply_to() {
  local machine_dir="$1"
  local target_settings="$machine_dir/settings.json"

  mkdir -p "$machine_dir"

  if [ ! -s "$target_settings" ]; then
    cp "$source_settings" "$target_settings"
    echo "==> Wrote VS Code remote settings to $target_settings"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "==> python3 unavailable; cannot merge $target_settings" >&2
    return 1
  fi

  python3 - "$source_settings" "$target_settings" <<'PY'
import json
import os
import sys
import tempfile

source_path, target_path = sys.argv[1], sys.argv[2]

with open(source_path) as handle:
    incoming = json.load(handle)

try:
    with open(target_path) as handle:
        existing = json.load(handle)
except (json.JSONDecodeError, OSError) as error:
    print(f"==> Cannot read {target_path}; leaving it untouched: {error}", file=sys.stderr)
    sys.exit(1)

if not isinstance(incoming, dict) or not isinstance(existing, dict):
    print("==> VS Code settings must be JSON objects; leaving existing settings untouched", file=sys.stderr)
    sys.exit(1)

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

print(f"==> Merged VS Code remote settings into {target_path}")
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
