#!/bin/bash

echo "==> Running install.sh from dotfiles..."

git config --global push.autoSetupRemote true
git config --global commit.gpgsign false

if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc" ]; then
  # Leave what's in place there but append customizations
  echo "source '/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc'" >> ~/.bashrc
fi

# Unfortunately, Codespaces doesn't have a way to open a default .code-workspace file,
# see https://github.com/microsoft/vscode-remote-release/issues/3665
file_path="/workspaces/.codespaces/.persistedshare/.workspace-opened"
dotfiles_dir="/workspaces/.codespaces/.persistedshare/dotfiles"

if [ ! -f "$file_path" ]; then
  if [ -d "/workspaces/github" ] && [ -d "/workspaces/github-ui" ] && [ -d "$dotfiles_dir" ]; then
    touch "$file_path"
    echo "==> First run, loading workspace..."
    code --reuse-window $dotfiles_dir/with-github-ui.code-workspace
  fi
elif [ -f "$file_path" ]; then
  echo "==> $file_path exists, workspace already opened."
fi
