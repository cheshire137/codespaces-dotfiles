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
