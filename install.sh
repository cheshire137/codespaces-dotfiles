#!/bin/bash

echo "==> Running install.sh from dotfiles..."

git config --global push.autoSetupRemote true
git config --global commit.gpgsign false

if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc" ]; then
  # Leave what's in place there but append customizations
  echo "source '/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc'" >> ~/.bashrc
fi
