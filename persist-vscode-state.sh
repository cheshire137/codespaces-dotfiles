#!/bin/bash
# Persist VS Code per-workspace state (Copilot chat sessions, file history,
# global session store) across Codespace stop/start by symlinking the
# ephemeral ~/.vscode-remote/data/User subdirs into /workspaces, which is
# the only durable mount in a Codespace.

set -e

PERSIST_ROOT="/workspaces/.codespaces/.persistedshare/vscode-user"
VSCODE_USER="$HOME/.vscode-remote/data/User"

[ -d "/workspaces/.codespaces/.persistedshare" ] || exit 0
[ -d "$VSCODE_USER" ] || exit 0

mkdir -p "$PERSIST_ROOT"

# workspaceStorage: per-workspace chat list, view state, etc.
# History:          VS Code's local file timeline (Timeline view)
# globalStorage:    Copilot chat session-store.db (used by "Local" target)
for d in workspaceStorage History globalStorage; do
  src="$PERSIST_ROOT/$d"
  dest="$VSCODE_USER/$d"
  mkdir -p "$src"

  # Already a symlink — nothing to do
  [ -L "$dest" ] && continue

  # First-run: seed persistent copy with whatever is currently in the
  # ephemeral location so we don't lose existing state, then replace.
  if [ -d "$dest" ]; then
    cp -an "$dest"/. "$src"/ 2>/dev/null || true
    rm -rf "$dest"
  fi
  ln -s "$src" "$dest"
done
