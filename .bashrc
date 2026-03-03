export EDITOR=vim
export VISUAL="$EDITOR"
export GIT_EDITOR="vim"

export HISTFILE=/workspaces/.codespaces/.persistedshare/.bash_history
# Write history each command due to Codespace sometimes not flushing
export PROMPT_COMMAND="history -a"
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoreboth

export VITE=1
export SERVICEOWNERS_SKIP=1
export RUBOCOP_SKIP=1
export SORBET_SKIP=1

if [ -d "/workspaces/github-ui" ]; then
	export PATH="/workspaces/github-ui/node_modules/.bin:$PATH"
fi

alias gco='git checkout'

killport() {
	if [ -z $1 ]; then
		echo 'Port is required. Usage: "killport 8000"';
		return
	fi
	local pid=`lsof  -i :$1 | grep LISTEN | awk '{print $2}'`
	if [ -z $pid ]; then
		echo "No process running on $1"
	else
		echo "Killing process [$pid]"
		kill $pid
	fi
}
echo "Run killport <port> to kill a process running on a specific port."

with_github_ui() {
	# Unfortunately, Codespaces doesn't have a way to open a default .code-workspace file,
	# see https://github.com/microsoft/vscode-remote-release/issues/3665
	file_path="/workspaces/.codespaces/.persistedshare/.with-github-ui-workspace-opened"
	dotfiles_dir="/workspaces/.codespaces/.persistedshare/dotfiles"

	if [ ! -f "$file_path" ]; then
		if [ -d "/workspaces/github" ] && [ -d "/workspaces/github-ui" ] && [ -d "$dotfiles_dir" ]; then
			if command -v code >/dev/null 2>&1; then
				touch "$file_path"
				echo "==> First run, loading workspace..."
				code --reuse-window $dotfiles_dir/with-github-ui.code-workspace
			else
				echo "==> VS Code command not found, unable to open workspace."
			fi
		fi
	elif [ -f "$file_path" ]; then
		echo "==> $file_path exists, workspace already opened."
	fi
}
echo "Run with_github_ui to open a VS Code workspace with github-ui included."
