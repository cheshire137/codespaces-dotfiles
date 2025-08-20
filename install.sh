#!/bin/bash

echo "==> Running install.sh from dotfiles..."

if [ -f "/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc" ]; then
  # Leave what's in place there but append customizations
  echo "source '/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc'" >> ~/.bashrc
fi
