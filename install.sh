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
git config --global core.editor "vim"


if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bash_profile" ]; then
  # Overwrite bash profile with my own
  cp /workspaces/.codespaces/.persistedshare/dotfiles/.bash_profile ~/.bash_profile
fi

instructions_source="/workspaces/.codespaces/.persistedshare/dotfiles/.instructions/copilot-quality-local.md"
instructions_target_dir="$HOME/.copilot"
instructions_target_file="${instructions_target_dir}/copilot-instructions.md"

if [ ! -f "$instructions_target_file" ] && [ -f "$instructions_source" ]; then
  echo "==> Copying Copilot instructions into $instructions_target_file"
  mkdir -p "$instructions_target_dir"
  cp "$instructions_source" "$instructions_target_file"
fi
