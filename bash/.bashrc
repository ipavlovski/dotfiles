#     __               __
#    / /_  ____ ______/ /_  __________
#   / __ \/ __ `/ ___/ __ \/ ___/ ___/
#  / /_/ / /_/ (__  ) / / / /  / /__
# /_.___/\__,_/____/_/ /_/_/   \___/


#  ==========================================
#              SHELL/TERM OPTIONS            
#  ==========================================

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# prevent stty lockup
stty -ixon

# prevent ^C characters printed in terminal after Ctrl-c
stty -echoctl

# update rows and columns after each command
shopt -s checkwinsize

# Use pattern '**' to match everything
shopt -s globstar

# do not auto-escape variables '\$' on complete
shopt -s direxpand

#  =============================
#              THEME            
#  =============================

# source dircolors color-theme
[[ -f "$HOME"/.config/dircolors ]] && eval $(dircolors -b "$HOME"/.config/dircolors)


#  ===========================
#              PS1            
#  ===========================

# need to use a non-breaking space: \u00A0
PS1='\e\[\033[1;34m\]::: \[\033[1;32m\]\u\[\033[1;34m\]@\[\033[1;31m\]\h\[\033[1;34m\] ::: $(pwd)\n\$ \[\033[0m\]'

#  =======================================
#              SHELL VARIABLES            
#  =======================================

# include local bin and scripts into executable path
export PATH="$PATH:~/.local/bin:~/.local/scripts"

# for usage in C-x C-e and fc (and other random cli-edits)
export EDITOR=vim

# since working with tmux, dont need less to scroll
export PAGER="/usr/bin/cat"

# override default cat-pager, since man is like an 'application'
export MANPAGER=/usr/bin/less

# improve less usability (colors, scroll, etc.)
export LESS='-XriF --mouse --wheel-lines=3'


#  ==========================================
#              XDG BASE DIRECTORY            
#  ==========================================

# XDG dirs
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache

# XDG cleanup
export PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export NODE_REPL_HISTORY=$XDG_DATA_HOME/node/node_repl_history
export GOPATH=$XDG_DATA_HOME/go
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export CARGO_HOME=$XDG_DATA_HOME/cargo
export WGETRC=$XDG_CONFIG_HOME/wget/wgetrc
export LESSHISTFILE=/dev/null
export INPUTRC=$XDG_CONFIG_HOME/readline/inputrc
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export SQLITE_HISTORY=$XDG_DATA_HOME/sqlite3/sqlite_history
export TS_NODE_HISTORY=$XDG_DATA_HOME/ts-node/ts_node_repl_history

#  ===============================
#              ALIASES            
#  ===============================


# ls/ll
alias ls='ls --color=auto'
alias ll='LC_COLLATE=C ls -AlhXv --time-style=+[%Y-%m-%d\ %T] --group-directories-first'

# add color to baic commands
alias ip='ip -c'
alias grep='grep --color=auto'
alias yay='yay --color=always'

# aliases for auto-expanding
alias grep-sort='grep -r --include="*.sh" -l query | xargs grep -c query | sort -n -t: -k2,2 -r'
alias find-root='find / -type f -name "filename" 2>/dev/null'

# dotfiles command for managing homedir 
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# xdg-based aliases to keep 
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias sqlite3='sqlite3 -init "$XDG_CONFIG_HOME"/sqlite3/sqliterc'


#  =================================
#              FUNCTIONS            
#  =================================

## calculator
c() { printf "%s\n" "$*" | bc ; }

# Usage: grepc "query" -H
grepc() { grep -P -hr -C 0 --group-separator=$'\n\n' "$@" ~/docs/scratches ; }

# Usage: grepl "query" -H
grepl() { grep -P -hr -C 0 --group-separator=$'\n\n' "$@" ~/docs/notes ; }

# $1: extension, $2: query
find-grep() {
    if [[ -z $1 ]]; then echo "Usage: find-grep 'ext' 'query'"; return; fi
    find . -type f -iname "*.$1" -exec grep --color=auto -iH "$2" {} \;
}

# preview pass command per level
pass-level() { pass "$@" | grep '^├──\|^└──' ; }

# copy current text in shell
copyline() { printf %s "$READLINE_LINE"| xsel -bi; }
bind -x  '"\C-y":copyline'

# copy last text in shell
copylast() { history -p '!!' | tr -d \\n | xsel -bi ; }
bind -x  '"\ey":copylast'

# copy path of a file (and print it also)
pwf() { realpath -e disk_usage.txt | tee >(tr -d '\n' | xsel -b) ; }

#  ========================================
#              BASH COMPLETIONS            
#  ========================================


# default bash completions
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# fuzzy-find bash completions
if [ -f /usr/share/fzf/comletion.bash ]; then
    . /usr/share/fzf/completion.bash
fi



#  ==================================
#              FUZZY-FIND            
#  ==================================


# enable fuzzyfind in tmux
export FZF_TMUX=1

# use ** to trigger fuzzyfind completion
export FZF_COMPLETION_TRIGGER='**'


#  ===============================================
#              MANUAL HISTORY HANDLING            
#  ===============================================

# dont save history file - manage it manually through .historydb
unset HISTFILE
export HISTTIMEFORMAT=''

# if need to 'ignore' history command -> prepend it with a space
export HISTCONTROL=ignorespace

logger=~/.local/share/logger/scripts/historydb-logger
[[ -f $logger ]] && source $logger



#  ==================================
#              TMUX LOGIN            
#  ==================================


# defualt session name
session_name='a'

# custom tmux session names depending on vscode-project
if [[ -n $VSCODE ]]; then
    if [[ "${VSCODE}" =~ .*vscode-scratch.* ]]; then
        session_name=s
    elif [[ "${VSCODE}" =~ .*vscode-samples.* ]]; then
        session_name=v
    else
        session_name=p
    fi
fi

# only boot-in tmux if this is NOT an SSH shell, or if tmux isn't running
[[ -z "$TMUX" && -z "$SSH_TTY" ]] && { tmux new-session -A -s $session_name; }
