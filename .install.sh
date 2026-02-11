#!/bin/bash

# Shell Environment Installation Script
# This script sets up a comprehensive shell environment with 1Password integration and ASCII welcome messages

set -e  # Exit on error

echo "🚀 Shell Environment Setup"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
SHELL_DIR="$DOTFILES_DIR/shell"
CONFIG_DIR="$DOTFILES_DIR/config"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Display ASCII welcome banner
show_welcome_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                   🚀 SHELL ENVIRONMENT SETUP 🚀             ║
║                                                              ║
║  Setting up your development environment with:              ║
║  • Modular shell configuration                              ║
║  • 1Password CLI integration                                ║
║  • ASCII welcome messages                                   ║
║  • Development workflow enhancements                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    local all_good=true

    # Check zsh
    if command -v zsh &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} zsh is available"
    else
        echo -e "  ${RED}✗${NC} zsh is not installed"
        all_good=false
    fi

    # Check Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "  ${GREEN}✓${NC} Oh My Zsh is installed"
    else
        echo -e "  ${YELLOW}!${NC} Oh My Zsh not found (this is optional)"
    fi

    # Check 1Password CLI
    if command -v op &> /dev/null; then
        local op_version=$(op --version)
        echo -e "  ${GREEN}✓${NC} 1Password CLI v$op_version is available"
    else
        echo -e "  ${YELLOW}!${NC} 1Password CLI not found (will provide setup instructions)"
    fi

    # Check git
    if command -v git &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Git is available"
    else
        echo -e "  ${RED}✗${NC} Git is not installed"
        all_good=false
    fi

    if [ "$all_good" = false ]; then
        echo -e "${RED}✗${NC} Some prerequisites are missing. Please install them and try again."
        exit 1
    fi

    echo -e "${GREEN}✓${NC} All prerequisites checked"
    echo ""
}

# Check existing setup
check_existing_setup() {
    echo "🔍 Checking existing shell setup..."

    # Check .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        echo -e "  ${GREEN}✓${NC} Found existing .zshrc"
        # Check if our configuration is already integrated
        if grep -q "Dotfiles Environment Setup" "$HOME/.zshrc" 2>/dev/null; then
            echo -e "  ${YELLOW}!${NC} Dotfiles configuration already integrated"
            read -p "Do you want to reinstall? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation cancelled."
                exit 0
            fi
        fi
    else
        echo -e "  ${YELLOW}!${NC} No .zshrc found - will create basic configuration"
    fi

    # Check .zprofile
    if [ -f "$HOME/.zprofile" ]; then
        echo -e "  ${GREEN}✓${NC} Found existing .zprofile (PATH management preserved)"
    fi

    echo ""
}

# Create directory structure
create_directory_structure() {
    echo "📁 Creating directory structure..."

    # Create main directories
    mkdir -p "$SHELL_DIR"
    mkdir -p "$CONFIG_DIR"

    echo -e "  ${GREEN}✓${NC} Created shell configuration directory: $SHELL_DIR"
    echo -e "  ${GREEN}✓${NC} Created config directory: $CONFIG_DIR"
    echo ""
}

# Create backup of existing files
create_backup() {
    echo "💾 Creating backup of existing configuration..."

    mkdir -p "$BACKUP_DIR"

    # Backup .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        echo -e "  ${GREEN}✓${NC} Backed up .zshrc"
    fi

    # Backup .zprofile if it exists
    if [ -f "$HOME/.zprofile" ]; then
        cp "$HOME/.zprofile" "$BACKUP_DIR/.zprofile"
        echo -e "  ${GREEN}✓${NC} Backed up .zprofile"
    fi

    echo -e "  ${BLUE}📁${NC} Backup location: $BACKUP_DIR"
    echo ""
}

# Create shell configuration files
create_shell_config() {
    echo "⚙️  Creating shell configuration files..."

    # Create exports.zsh
    cat > "$SHELL_DIR/exports.zsh" << 'EOF'
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
EOF

    # Create aliases.zsh
    cat > "$SHELL_DIR/aliases.zsh" << 'EOF'
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
alias weather="curl -s wttr.in"
alias qr="qrencode -t utf8"
alias backup-dotfiles="tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/dotfiles"
EOF

    # Create functions.zsh
    cat > "$SHELL_DIR/functions.zsh" << 'EOF'
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

# Find and grep in files
fgrep() {
    if [ $# -eq 0 ]; then
        echo "Usage: fgrep <pattern> [directory]"
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
EOF

    echo -e "  ${GREEN}✓${NC} Created exports.zsh"
    echo -e "  ${GREEN}✓${NC} Created aliases.zsh"
    echo -e "  ${GREEN}✓${NC} Created functions.zsh"
    echo ""
}

# Create welcome system
create_welcome_system() {
    echo "🎨 Creating ASCII welcome system..."

    # Create ASCII art file
    cat > "$CONFIG_DIR/ascii-art.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    🚀 WELCOME TO YOUR 🚀                    ║
║                  DEVELOPMENT ENVIRONMENT                     ║
║                                                              ║
║  Your shell is now equipped with:                           ║
║  • 1Password CLI integration  🔐                            ║
║  • Enhanced productivity aliases  ⚡                        ║
║  • Development helper functions  🛠️                         ║
║  • ASCII welcome messages  🎨                               ║
║                                                              ║
║  Type 'op-status' to check 1Password connection             ║
║  Type 'op-setup-env' to load development credentials        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

    # Create welcome.zsh
    cat > "$SHELL_DIR/welcome.zsh" << 'EOF'
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
        echo "🔧 Shell: $(echo $SHELL | xargs basename)"

        # Check 1Password status
        if command -v op &> /dev/null; then
            if op whoami &>/dev/null; then
                echo "🔐 1Password: ✅ Signed in as $(op whoami)"
            else
                echo "🔐 1Password: ⚠️  Not signed in (run 'op signin')"
            fi
        else
            echo "🔐 1Password: ❌ CLI not installed"
        fi

        # Show current directory
        echo "📁 Location: $(pwd)"

        # Show git status if in a git repo
        if git rev-parse --git-dir &>/dev/null; then
            local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
            local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$status" -eq 0 ]; then
                echo "🌳 Git: $branch (clean)"
            else
                echo "🌳 Git: $branch ($status changes)"
            fi
        fi

        echo ""
    fi
}

# Show welcome on new shell sessions (conditionally)
# Only show once per terminal session to avoid spam
if [[ -o interactive && -z "$DOTFILES_WELCOME_SHOWN" ]]; then
    # Small delay to let Oh My Zsh finish loading
    (sleep 0.1 && show-welcome) &
    export DOTFILES_WELCOME_SHOWN=1
fi

# Function to manually trigger welcome message
welcome() {
    show-welcome
}

# Function to show system information
sysinfo() {
    echo "🖥️  System Information:"
    echo "   OS: $(uname -s) $(uname -r)"
    echo "   Shell: $SHELL"
    echo "   Terminal: $TERM"
    echo "   User: $(whoami)"
    echo "   Home: $HOME"
    echo "   PWD: $(pwd)"
    echo ""

    # Show disk usage
    echo "💾 Disk Usage:"
    df -h / | tail -1 | awk '{print "   Root: " $3 " used / " $2 " total (" $5 " full)"}'
    echo ""

    # Show memory usage (macOS)
    if command -v vm_stat &> /dev/null; then
        echo "🧠 Memory Usage:"
        vm_stat | head -4 | awk 'NR==2{pages_free=$3} NR==3{pages_active=$3} NR==4{pages_inactive=$3} END{total=pages_free+pages_active+pages_inactive; used=pages_active+pages_inactive; printf "   Used: %.1f GB / Total: %.1f GB (%.1f%% used)\n", used*4096/1024/1024/1024, total*4096/1024/1024/1024, used/total*100}'
        echo ""
    fi

    # Show network info
    echo "🌐 Network:"
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
EOF

    echo -e "  ${GREEN}✓${NC} Created ascii-art.txt"
    echo -e "  ${GREEN}✓${NC} Created welcome.zsh"
    echo ""
}

# Create 1Password setup documentation
create_1password_docs() {
    echo "📖 Creating 1Password setup documentation..."

    cat > "$CONFIG_DIR/1password-setup.md" << 'EOF'
# 1Password CLI Setup Guide

This guide helps you set up 1Password CLI integration for secure credential management in your shell environment.

## Prerequisites

1. **1Password Desktop App**: Install from https://1password.com/downloads
2. **1Password CLI**: Install with Homebrew:
   ```bash
   brew install 1password-cli
   ```

## Setup Steps

### 1. Enable 1Password CLI in Desktop App

1. Open 1Password desktop app
2. Go to Settings → Developer
3. Enable "Connect with 1Password CLI"

### 2. Sign In to 1Password CLI

```bash
# Sign in (you'll be prompted for your account details)
op signin

# Or sign in to a specific account
op signin my.1password.com user@example.com
```

### 3. Create a "dotfiles" Vault

1. In 1Password desktop app, create a new vault called "dotfiles"
2. This vault will store all your development credentials

### 4. Add Your Credentials

Add items to your "dotfiles" vault with these recommended names and fields:

#### GitHub Credentials
- **Item Name**: "GitHub"
- **Fields**:
  - `api-token` (your GitHub Personal Access Token)

#### Anthropic API Key
- **Item Name**: "Anthropic"
- **Fields**:
  - `api-key` (your Anthropic API key for Claude)

#### SSH Key
- **Item Name**: "SSH Key"
- **Fields**:
  - `private key` (your SSH private key content)

### 5. Test the Integration

```bash
# Check if you're signed in
op whoami

# Test retrieving a credential
op read "op://dotfiles/GitHub/api-token"

# Set up development environment
op-setup-env

# Check 1Password status
op-status
```

## Available Shell Functions

Once set up, you can use these shell functions:

- `op-status` - Check 1Password connection status
- `op-setup-env` - Load development environment variables from 1Password
- `op-get-env <item> <field>` - Retrieve specific credentials
- `op-inject-ssh` - Load SSH key for git operations

## Security Best Practices

1. **Never commit credentials to git** - Always use 1Password for secrets
2. **Use vault-specific organization** - Keep development credentials in the "dotfiles" vault
3. **Regular rotation** - Update API keys and tokens regularly
4. **Minimal permissions** - Use tokens with minimal required permissions
5. **Session management** - 1Password CLI sessions expire automatically for security

## Troubleshooting

### "not currently signed in" Error

```bash
# Re-authenticate
op signin
```

### Can't Find Item or Field

```bash
# List all vaults
op vault list

# List items in dotfiles vault
op item list --vault dotfiles

# Get item details
op item get "GitHub" --vault dotfiles
```

### Desktop App Integration Issues

1. Restart 1Password desktop app
2. Re-enable CLI integration in Settings → Developer
3. Try signing out and back in: `op signout && op signin`

## Adding New Credentials

To add support for new development tools:

1. **Add the credential to 1Password**:
   - Create item in "dotfiles" vault
   - Use clear, consistent naming

2. **Update shell/functions.zsh**:
   - Add export line to `op-setup-env()` function
   - Follow the existing pattern

3. **Test the integration**:
   ```bash
   # Source the updated configuration
   source ~/.zshrc

   # Test loading the new credential
   op-setup-env
   ```

## Example Workflow

```bash
# Start of day: set up development environment
op signin                    # Sign in to 1Password
op-setup-env                # Load all development credentials
op-inject-ssh               # Load SSH key for git operations

# Your environment variables are now set:
# - $GITHUB_TOKEN
# - $ANTHROPIC_API_KEY
# - SSH key loaded for git

# Work on your projects with authenticated access
git clone git@github.com:user/repo.git
claude --version  # Uses $ANTHROPIC_API_KEY
gh api user       # Uses $GITHUB_TOKEN
```

This setup ensures your credentials are secure, never stored in plaintext files, and easily accessible for development work.
EOF

    echo -e "  ${GREEN}✓${NC} Created 1password-setup.md"
    echo ""
}

# Integrate with existing .zshrc
integrate_with_zshrc() {
    echo "🔧 Integrating with shell configuration..."

    # Ensure .zshrc exists
    if [ ! -f "$HOME/.zshrc" ]; then
        echo "# Basic zsh configuration" > "$HOME/.zshrc"
        echo "# Oh My Zsh installation directory" >> "$HOME/.zshrc"
        echo 'export ZSH="$HOME/.oh-my-zsh"' >> "$HOME/.zshrc"
        echo 'ZSH_THEME="robbyrussell"' >> "$HOME/.zshrc"
        echo 'plugins=(git)' >> "$HOME/.zshrc"
        echo 'source $ZSH/oh-my-zsh.sh' >> "$HOME/.zshrc"
        echo ""
        echo -e "  ${BLUE}ℹ${NC}  Created basic .zshrc configuration"
    fi

    # Check if our configuration is already integrated
    if grep -q "Dotfiles Environment Setup" "$HOME/.zshrc"; then
        echo -e "  ${YELLOW}!${NC} Configuration already integrated, updating..."
        # Remove old configuration block
        sed -i.bak '/# Dotfiles Environment Setup/,/# End Dotfiles Environment Setup/d' "$HOME/.zshrc"
    fi

    # Add our configuration to .zshrc
    cat >> "$HOME/.zshrc" << EOF

# Dotfiles Environment Setup
# Added by dotfiles installation script - $(date)
if [ -f "$HOME/dotfiles/shell/exports.zsh" ]; then
    source "$HOME/dotfiles/shell/exports.zsh"
fi
if [ -f "$HOME/dotfiles/shell/aliases.zsh" ]; then
    source "$HOME/dotfiles/shell/aliases.zsh"
fi
if [ -f "$HOME/dotfiles/shell/functions.zsh" ]; then
    source "$HOME/dotfiles/shell/functions.zsh"
fi
if [ -f "$HOME/dotfiles/shell/welcome.zsh" ]; then
    source "$HOME/dotfiles/shell/welcome.zsh"
fi
# End Dotfiles Environment Setup
EOF

    echo -e "  ${GREEN}✓${NC} Successfully integrated with .zshrc"
    echo ""
}

# Validate installation
validate_installation() {
    echo "✅ Validating installation..."

    local all_good=true

    # Check shell files
    for file in "exports.zsh" "aliases.zsh" "functions.zsh" "welcome.zsh"; do
        if [ -f "$SHELL_DIR/$file" ]; then
            echo -e "  ${GREEN}✓${NC} $file created"
        else
            echo -e "  ${RED}✗${NC} $file missing"
            all_good=false
        fi
    done

    # Check config files
    if [ -f "$CONFIG_DIR/ascii-art.txt" ]; then
        echo -e "  ${GREEN}✓${NC} ASCII art file created"
    else
        echo -e "  ${RED}✗${NC} ASCII art file missing"
        all_good=false
    fi

    if [ -f "$CONFIG_DIR/1password-setup.md" ]; then
        echo -e "  ${GREEN}✓${NC} 1Password documentation created"
    else
        echo -e "  ${RED}✗${NC} 1Password documentation missing"
        all_good=false
    fi

    # Check .zshrc integration
    if grep -q "Dotfiles Environment Setup" "$HOME/.zshrc"; then
        echo -e "  ${GREEN}✓${NC} Shell configuration integrated"
    else
        echo -e "  ${RED}✗${NC} Shell configuration not integrated"
        all_good=false
    fi

    if [ "$all_good" = true ]; then
        echo -e "  ${GREEN}✅${NC} All components validated successfully"
    else
        echo -e "  ${RED}❌${NC} Some components failed validation"
    fi

    echo ""
}

# Show completion banner and next steps
show_completion() {
    echo -e "${GREEN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                      🎉 SETUP COMPLETE! 🎉                  ║
║                                                              ║
║  Your shell environment is now enhanced with:               ║
║  ✅ Modular configuration system                            ║
║  ✅ 1Password CLI integration                               ║
║  ✅ Development productivity aliases                        ║
║  ✅ ASCII welcome messages                                  ║
║  ✅ Helper functions and utilities                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo ""
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo ""
    echo "1. ${YELLOW}Restart your shell${NC} or run: ${BLUE}source ~/.zshrc${NC}"
    echo ""
    echo "2. ${YELLOW}Set up 1Password CLI${NC} (if not already done):"
    echo "   ${BLUE}brew install 1password-cli${NC}"
    echo "   ${BLUE}op signin${NC}"
    echo "   📖 See: ${BLUE}$CONFIG_DIR/1password-setup.md${NC}"
    echo ""
    echo "3. ${YELLOW}Test the integration${NC}:"
    echo "   ${BLUE}op-status${NC}              # Check 1Password connection"
    echo "   ${BLUE}op-setup-env${NC}           # Load development credentials"
    echo "   ${BLUE}welcome${NC}                # Show welcome message"
    echo "   ${BLUE}sysinfo${NC}                # Show system information"
    echo ""
    echo "4. ${YELLOW}Explore new aliases and functions${NC}:"
    echo "   ${BLUE}ll${NC}                     # Enhanced ls"
    echo "   ${BLUE}..${NC}, ${BLUE}...${NC}, ${BLUE}....${NC}            # Quick navigation"
    echo "   ${BLUE}mkcd <dir>${NC}             # Make directory and cd"
    echo "   ${BLUE}extract <file>${NC}         # Extract any archive"
    echo "   ${BLUE}weather [city]${NC}         # Get weather info"
    echo "   ${BLUE}port-kill <port>${NC}       # Kill process on port"
    echo ""
    echo "5. ${YELLOW}Backup information${NC}:"
    echo "   📁 Original files backed up to: ${BLUE}$BACKUP_DIR${NC}"
    echo ""
    echo "${GREEN}Happy coding! 🚀${NC}"
    echo ""
}

# Main installation function
main() {
    # Show welcome banner
    show_welcome_banner

    # Perform checks
    check_prerequisites
    check_existing_setup

    # Create backup
    create_backup

    # Create directory structure
    create_directory_structure

    # Create configuration files
    create_shell_config
    create_welcome_system
    create_1password_docs

    # Integrate with shell
    integrate_with_zshrc

    # Validate installation
    validate_installation

    # Show completion
    show_completion
}

# Run main function
main "$@"