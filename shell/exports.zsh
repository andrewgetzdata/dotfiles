#!/bin/zsh

# Shell Environment Exports
# This file contains environment variables and PATH management
# Sourced from .zshrc after Oh My Zsh initialization

# Development environment variables
export EDITOR="code"
export VISUAL="$EDITOR"

# Development tools
export HOMEBREW_NO_AUTO_UPDATE=1

# Go development
if command -v go &> /dev/null; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Node.js development
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
fi

# Python development
export PYTHONDONTWRITEBYTECODE=1

# Claude Code
if [ -f "$HOME/.local/bin/claude" ]; then
    export CLAUDE_INSTALLED=1
fi

# Custom bin directories (supplement existing PATH from .zprofile)
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
