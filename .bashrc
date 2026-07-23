### Directory shortcuts and settings
export dt="$HOME/Desktop"
export dl="$HOME/Downloads"
export dc="$HOME/Documents"
export pc="$HOME/Pictures"
export vd="$HOME/Videos"
export as="$HOME/Assets"
export bn="$HOME/Binaries"
export so="$HOME/src"
export va="$HOME/Vault"
export nts="$HOME/Documents/notes"
export bin="$HOME/.local/bin"
export rc="$HOME/.bashrc"

export EDITOR=vim
export SUDO_EDITOR="$EDITOR"

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# I alt+f4 out of windows so much so i'm writing every command
export PROMPT_COMMAND="history -a"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# you can use ** in glob to recurse into directories
shopt -s globstar
# automatically updates window size
shopt -s checkwinsize
shopt -s histappend
shopt -u cdable_vars

# Only continue if not running interactively
case $- in *i*) ;; *) return;; esac



### Keybinds
# Ctrl + Backspace: Delete one word backward
bind '"\C-h": backward-kill-word'

# End + Delete: Delete whole line
bind '"\e[1;2F": kill-line'



### Aliases and functions
alias mv='mv -i'
alias ls='ls --color=auto -AF'
alias la='command ls --color=auto -a'
alias l='command ls --color=auto'
alias ll='command ls -alFh'
alias cp='cp -r'
alias d='cd'
alias v='vim'
alias quit='exit'
alias ':q'="exit"
alias pse="ps -e"

alias grep='grep --color=auto -i -P'

# Cool grep options:
## . matches any character
## *: 0+, +; 1+ {a,b}: a-b
## o (nly match)
## n (include line numbers, follow with a | cut -d: -f1 to get them out)
## v (invert match)
## i(gnore case)
## P (use perl's backslash regex - \w(ord), not \W(ord), \s(pace), \< beginning of word, \> end of word)
##   character classes: [a-zA-Z] (or [a-z] with -i), you can match not with ^ at beginning ([^a-z])

cd() {
	builtin cd "$@" && ls
}

cdback() {
	local count=${1:-1}
	local path=""
	for ((i=0; i<count; i++)); do path="../$path"; done
	cd "$path"
}
alias '..'=cdback

clip() {
	# prints to the terminal
	tee /dev/tty | clip
	printf '\nCopied to clipboard.\n'
}
alias copy="clip"

skconfig() {
	git --git-dir="$HOME"/.skconfig --work-tree="$HOME" "$@"
}
builtin source /mingw64/share/bash-completion/completions/git
__git_complete skconfig git


rm() {
	local files_to_delete=()
	local rec=false
	local force=false
	local use_recycle=false

	for arg in "$@"; do
		if [[ "$arg" == -* ]] ; then
			if [[ "$arg" == -*r* ]] || [[ "$arg" == -*R* ]] ; then
				rec=true
			fi

			if [[ "$arg" == -*f* ]] ; then
				force=true
			fi
		else
			# Save actual file/folder paths to an array
			files_to_delete+=("$arg")
		fi
	done

	if [ "$rec" = true ] && [ "$force" = true ]; then
		use_recycle=true
	fi

	if [ "$use_recycle" = true ]; then
		if [ ${#files_to_delete[@]} -eq 0 ]; then
			command rm "$@"
			return
		fi

		for item in "${files_to_delete[@]}"; do
			if [ -e "$item" ]; then
				# Convert path to absolute Windows format (e.g., C:\path\to\dir)
				local win_path=$(cygpath -w -a "$item")

				# Use VisualBasic library which handles both files and directory structures safely
				powershell.exe -Command "Add-Type -AssemblyName Microsoft.VisualBasic; if (Test-Path '$win_path' -PathType Container) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory('$win_path', 'OnlyErrorDialogs', 'SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('$win_path', 'OnlyErrorDialogs', 'SendToRecycleBin') }"
				echo "Sent folder to Windows Recycle Bin: $item"
			else
				echo "rm: '$item': No such file or directory"
			fi
		done
	else
		command rm "$@"
	fi
}
