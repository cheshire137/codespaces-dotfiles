#!/bin/bash

echo "==> Running install.sh from dotfiles..."

if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc" ]; then
  # Leave what's in place there but append customizations
  echo "source '/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc'" >> ~/.bashrc
fi

git config --global user.name "Sarah Vessels"
git config --global user.email "cheshire137@gmail.com"
git config --global init.defaultBranch main
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global commit.gpgsign false
git config --global alias.co checkout
git config --global alias.cp cherry-pick
if command -v vim >/dev/null 2>&1; then
  git config --global core.editor "vim"
else
  git config --global core.editor "vi"
fi


if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bash_profile" ]; then
  # Overwrite bash profile with my own
  cp /workspaces/.codespaces/.persistedshare/dotfiles/.bash_profile ~/.bash_profile
fi

instructions_source="/workspaces/.codespaces/.persistedshare/dotfiles/.instructions/copilot-quality-local.md"
instructions_target_dir="$HOME/.github"
instructions_target_file="${instructions_target_dir}/copilot-instructions.md"

if [ ! -f "$instructions_target_file" ] && [ -f "$instructions_source" ]; then
  echo "==> Copying Copilot instructions into $instructions_target_file"
  mkdir -p "$instructions_target_dir"
  cp "$instructions_source" "$instructions_target_file"
fi

# Load my personal Copilot skills from cheshire137/agent-skills into
# ~/.copilot/skills so they're available to Copilot CLI in every codespace.
#
# Permissions: the built-in codespace GITHUB_TOKEN is scoped to the codespace's
# own repository (e.g. github/github) and CANNOT read a private personal repo.
# So this needs a Codespaces user secret named AGENT_SKILLS_TOKEN holding a
# fine-grained PAT with read-only Contents access to cheshire137/agent-skills.
# Create it at: https://github.com/settings/codespaces (Secrets) and grant it to
# the repos you open codespaces in. Without the secret this block no-ops.
load_personal_skills() {
  [ "${CODESPACES:-}" = "true" ] || return 0

  local repo="cheshire137/agent-skills"
  local skills_dir="$HOME/.copilot/skills"
  local clone_dir="$HOME/.agent-skills"
  local token="${AGENT_SKILLS_TOKEN:-}"

  # Best-effort fallback (works in codespaces on my own repos where the built-in
  # token happens to grant access); harmless when it doesn't.
  if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
    token="$(gh auth token 2>/dev/null || true)"
  fi

  if [ -z "$token" ]; then
    echo "==> Skipping personal skills: set an AGENT_SKILLS_TOKEN Codespaces secret to enable"
    return 0
  fi

  echo "==> Loading personal Copilot skills from $repo"
  rm -rf "$clone_dir"
  local basic
  basic="$(printf 'x-access-token:%s' "$token" | base64 | tr -d '\n')"
  if ! git clone --quiet --depth 1 \
      -c http.extraHeader="Authorization: Basic ${basic}" \
      "https://github.com/${repo}.git" "$clone_dir"; then
    echo "==> Could not clone $repo (check the AGENT_SKILLS_TOKEN secret's scope)"
    return 0
  fi

  mkdir -p "$skills_dir"
  # Symlink each skill directory (one containing a SKILL.md) into ~/.copilot/skills.
  for skill_md in "$clone_dir"/*/SKILL.md; do
    [ -e "$skill_md" ] || continue
    local name
    name="$(basename "$(dirname "$skill_md")")"
    ln -sfn "${clone_dir}/${name}" "${skills_dir}/${name}"
    echo "    linked skill: ${name}"
  done
}

load_personal_skills

# Persist VS Code workspaceStorage / History / globalStorage across
# Codespace restarts. Cheap, idempotent; bails out outside Codespaces.
if [ -x "/workspaces/.codespaces/.persistedshare/dotfiles/persist-vscode-state.sh" ]; then
  /workspaces/.codespaces/.persistedshare/dotfiles/persist-vscode-state.sh || true
fi
