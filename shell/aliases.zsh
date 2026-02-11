#!/bin/zsh

# Shell Environment Aliases
# This file contains custom aliases for productivity
# Sourced from .zshrc after Oh My Zsh initialization

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# List aliases (enhanced)
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias lh="ls -lh"
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Git aliases (supplement Oh My Zsh git plugin)
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gcam="git commit -am"
alias glog="git log --oneline --graph --decorate"

# Development aliases
alias py="python3"
alias pip="pip3"
alias serve="python3 -m http.server"
alias npmls="npm list --depth=0"
alias yarnls="yarn list --depth=0"

# System aliases
alias reload="source ~/.zshrc && echo 'Shell reloaded!'"
alias zshconfig="$EDITOR ~/.zshrc"
alias dotfiles="cd $HOME/dotfiles"

# 1Password aliases (if available)
if command -v op &> /dev/null; then
    alias op-signin="eval \$(op signin)"
    alias op-whoami="op whoami"
    alias op-env="op-setup-env"
    alias op-ssh="op-inject-ssh"
fi

# Claude Code aliases (if available)
if command -v claude &> /dev/null; then
    alias ai="claude"
    alias code-review="claude -p 'Review this code for issues, security vulnerabilities, and improvements'"
    alias code-test="claude -p 'Generate comprehensive tests for this code'"
    alias code-docs="claude -p 'Generate documentation for this code'"
fi

# Docker aliases (if Docker is available)
if command -v docker &> /dev/null; then
    alias dps="docker ps"
    alias dpa="docker ps -a"
    alias di="docker images"
    alias dex="docker exec -it"
    alias dlog="docker logs -f"
    alias dstop="docker stop"
    alias drm="docker rm"
    alias drmi="docker rmi"
    alias dprune="docker system prune -f"
fi

# Productivity aliases
alias myip="curl -s ifconfig.me"
alias qr="qrencode -t utf8"
alias backup-dotfiles="tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/dotfiles"
