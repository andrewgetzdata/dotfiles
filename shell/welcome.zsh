#!/bin/zsh

# Shell Environment Welcome System
# This file contains ASCII art display and welcome functions
# Sourced from .zshrc after Oh My Zsh initialization

# Display ASCII welcome banner
show-welcome() {
    # Only show welcome in interactive shells
    if [[ ! -o interactive ]]; then
        return
    fi

    local config_dir="$HOME/dotfiles/config"

    if [ -f "$config_dir/ascii-art.txt" ]; then
        echo ""
        cat "$config_dir/ascii-art.txt"
        echo ""

        # Show environment info
        echo "Shell: $(echo $SHELL | xargs basename)"

        # Show current directory
        echo "Location: $(pwd)"

        # Show git status if in a git repo
        if git rev-parse --git-dir &>/dev/null; then
            local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
            local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$status" -eq 0 ]; then
                echo "Git: $branch (clean)"
            else
                echo "Git: $branch ($status changes)"
            fi
        fi

        echo ""
    fi
}

# Show welcome on new shell sessions (conditionally)
# Only show once per terminal session to avoid spam
if [[ -o interactive && -z "$DOTFILES_WELCOME_SHOWN" ]]; then
    show-welcome
    export DOTFILES_WELCOME_SHOWN=1
fi

# Function to manually trigger welcome message
welcome() {
    show-welcome
}

# Function to show system information
sysinfo() {
    echo "System Information:"
    echo "   OS: $(uname -s) $(uname -r)"
    echo "   Shell: $SHELL"
    echo "   Terminal: $TERM"
    echo "   User: $(whoami)"
    echo "   Home: $HOME"
    echo "   PWD: $(pwd)"
    echo ""

    # Show disk usage
    echo "Disk Usage:"
    df -h / | tail -1 | awk '{print "   Root: " $3 " used / " $2 " total (" $5 " full)"}'
    echo ""

    # Show memory usage (macOS)
    if command -v vm_stat &> /dev/null; then
        echo "Memory Usage:"
        vm_stat | head -4 | awk 'NR==2{pages_free=$3} NR==3{pages_active=$3} NR==4{pages_inactive=$3} END{total=pages_free+pages_active+pages_inactive; used=pages_active+pages_inactive; printf "   Used: %.1f GB / Total: %.1f GB (%.1f%% used)\n", used*4096/1024/1024/1024, total*4096/1024/1024/1024, used/total*100}'
        echo ""
    fi

    # Show network info
    echo "Network:"
    if command -v ifconfig &> /dev/null; then
        local ip=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
        if [ -n "$ip" ]; then
            echo "   Local IP: $ip"
        fi
    fi

    # Show external IP
    if command -v curl &> /dev/null; then
        local external_ip=$(curl -s --max-time 3 ifconfig.me 2>/dev/null)
        if [ -n "$external_ip" ]; then
            echo "   External IP: $external_ip"
        fi
    fi
    echo ""
}
