#!/bin/zsh

# Shell Environment Functions
# This file contains utility functions
# Sourced from .zshrc after Oh My Zsh initialization

# Development helper functions

# Create a new project directory with standard structure
new-project() {
    if [ $# -eq 0 ]; then
        echo "Usage: new-project <project-name>"
        return 1
    fi

    local project_name="$1"

    mkdir -p "$project_name"/{src,tests,docs}
    cd "$project_name"

    # Initialize git if available
    if command -v git &> /dev/null; then
        git init
        echo "# $project_name" > README.md
        git add README.md
        git commit -m "Initial commit"
    fi

    echo "Created project: $project_name"
    pwd
}

# Extract any archive
extract() {
    if [ $# -eq 0 ]; then
        echo "Usage: extract <file>"
        return 1
    fi

    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find and search in files
findgrep() {
    if [ $# -eq 0 ]; then
        echo "Usage: findgrep <pattern> [directory]"
        return 1
    fi

    local pattern="$1"
    local dir="${2:-.}"

    find "$dir" -type f -name "*.md" -o -name "*.txt" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" | xargs grep -l "$pattern"
}

# Make a directory and cd into it
mkcd() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi

    mkdir -p "$1" && cd "$1"
}

# Get the weather for a specific location
weather() {
    local location="${1:-}"
    if [ -z "$location" ]; then
        curl -s "wttr.in/?format=%l:+%C+%t+%h+%w"
    else
        curl -s "wttr.in/$location?format=%l:+%C+%t+%h+%w"
    fi
}

# Port killer function
port-kill() {
    if [ $# -eq 0 ]; then
        echo "Usage: port-kill <port-number>"
        return 1
    fi

    local port="$1"
    local pids=$(lsof -ti:$port)

    if [ -n "$pids" ]; then
        echo "Killing processes on port $port: $pids"
        kill -9 $pids
    else
        echo "No processes found on port $port"
    fi
}
