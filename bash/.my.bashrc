test -s ~/.alias && . ~/.alias || true

set -o vi

# rustup mirror
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

# prompt git branch
export PS1='\u@\h \[\e[32m\]\w\[\e[91m\]$(__git_ps1)\[\e[00m\]$ '

# script
PATH="$PATH:$HOME/sh"

