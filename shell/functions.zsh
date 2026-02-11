#!/bin/zsh

# Shell Environment Functions
# This file contains utility functions and 1Password helpers
# Sourced from .zshrc after Oh My Zsh initialization

# 1Password helper functions
if command -v op &> /dev/null; then

    # Retrieve environment variable from 1Password
    op-get-env() {
        if [ $# -eq 0 ]; then
            echo "Usage: op-get-env <vault-item> <field>"
            echo "Example: op-get-env 'GitHub' 'api-token'"
            return 1
        fi

        local item="$1"
        local field="$2"

        if [ -z "$field" ]; then
            field="password"
        fi

        op read "op://dotfiles/$item/$field" 2>/dev/null || {
            echo "❌ Failed to retrieve $field from $item"
            echo "Make sure you're signed in: op signin"
            echo "And that the item exists in your 'dotfiles' vault"
            return 1
        }
    }

    # Set up development environment variables from 1Password
    op-setup-env() {
        echo "🔐 Setting up development environment from 1Password..."

        # GitHub token
        if GITHUB_TOKEN=$(op-get-env "GitHub" "api-token"); then
            export GITHUB_TOKEN
            echo "✓ GitHub API token loaded"
        fi

        # Anthropic API key for Claude
        if ANTHROPIC_API_KEY=$(op-get-env "Anthropic" "api-key"); then
            export ANTHROPIC_API_KEY
            echo "✓ Anthropic API key loaded"
        fi

        # Add more environment variables as needed
        # if CUSTOM_TOKEN=$(op-get-env "Service" "token"); then
        #     export CUSTOM_TOKEN
        #     echo "✓ Custom token loaded"
        # fi

        echo "🚀 Development environment ready!"
    }

    # Inject SSH key from 1Password for git operations
    op-inject-ssh() {
        echo "🔐 Injecting SSH key from 1Password..."

        if ! op whoami &>/dev/null; then
            echo "❌ Not signed in to 1Password. Run: op signin"
            return 1
        fi

        # Attempt to load SSH key from 1Password
        if op read "op://dotfiles/SSH Key/private key" | ssh-add - 2>/dev/null; then
            echo "✓ SSH key loaded successfully"
            ssh-add -l
        else
            echo "❌ Failed to load SSH key from 1Password"
            echo "Make sure you have an 'SSH Key' item in your 'dotfiles' vault"
            echo "with a 'private key' field containing your SSH private key"
        fi
    }

    # Check 1Password connection status
    op-status() {
        if op whoami &>/dev/null; then
            local account=$(op whoami)
            echo "✅ Signed in to 1Password as: $account"
        else
            echo "❌ Not signed in to 1Password"
            echo "Run: op signin"
        fi
    }

else
    # Provide helpful messages when 1Password CLI is not available
    op-get-env() {
        echo "❌ 1Password CLI not installed"
        echo "Install with: brew install 1password-cli"
    }

    op-setup-env() {
        echo "❌ 1Password CLI not installed"
        echo "Install with: brew install 1password-cli"
    }

    op-inject-ssh() {
        echo "❌ 1Password CLI not installed"
        echo "Install with: brew install 1password-cli"
    }

    op-status() {
        echo "❌ 1Password CLI not installed"
        echo "Install with: brew install 1password-cli"
    }
fi

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

    echo "✅ Created project: $project_name"
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
