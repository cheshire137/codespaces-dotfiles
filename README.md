# codespaces-dotfiles
Dotfiles for installation in a GitHub Codespace upon creation.

<img width="964" height="193" alt="screenshot of Automatically Install Dotfiles setting in GitHub Codespaces settings" src="https://github.com/user-attachments/assets/1bd701c3-b71f-40f4-9707-2c76330c456a" />

-- https://github.com/settings/codespaces

## VS Code remote settings

`install.sh` applies `vscode/machine-settings.json` when running in Codespaces. It gives remote windows blue title, status, and activity bars and uses the default opener for GitHub URLs.

The script merges settings into `data/Machine/settings.json` under `~/.vscode-remote` and `~/.vscode-server` when those dirs exist. If neither exists yet, it creates the `~/.vscode-remote` settings. Unrelated settings and nested keys stay in place; keys in the dotfiles config win.

Existing settings must be JSON without comments or trailing commas. If a merge fails, the script reports an error and leaves that file untouched. Merging needs `python3`.

To apply changes in an existing codespace, run `bash /workspaces/.codespaces/.persistedshare/dotfiles/apply-vscode-settings.sh`.
