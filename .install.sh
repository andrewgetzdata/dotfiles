#!/bin/bash

# Dotfiles Installation Script
# Sets up zsh + tmux + nvim + Claude Code environment

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

info()  { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
fail()  { echo -e "${RED}[error]${NC} $1"; }

# 1. Check prerequisites
echo ""
echo "Checking prerequisites..."
missing=0
for cmd in zsh git; do
    if command -v "$cmd" &>/dev/null; then
        info "$cmd found"
    else
        fail "$cmd not found"
        missing=1
    fi
done
for cmd in tmux nvim ripgrep; do
    if command -v "$cmd" &>/dev/null || { [ "$cmd" = "ripgrep" ] && command -v rg &>/dev/null; }; then
        info "$cmd found"
    else
        warn "$cmd not found (install with: brew install $cmd)"
    fi
done
if [ "$missing" -eq 1 ]; then
    fail "Required tools missing. Install them and re-run."
    exit 1
fi
echo ""

# 2. Backup existing files
echo "Backing up existing configs..."
mkdir -p "$BACKUP_DIR"
for f in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.tmux.conf"; do
    [ -f "$f" ] && cp "$f" "$BACKUP_DIR/" && info "backed up $(basename $f)"
done
[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim" && info "backed up nvim config"
[ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" "$BACKUP_DIR/" && info "backed up CLAUDE.md"
[ -f "$HOME/.claude/settings.json" ] && cp "$HOME/.claude/settings.json" "$BACKUP_DIR/settings.json.bak" && info "backed up settings.json"
echo "Backups in: $BACKUP_DIR"
echo ""

# 3. Append source lines to ~/.zshrc
echo "Configuring shell..."
if ! grep -q "# Dotfiles Environment Setup" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Dotfiles Environment Setup
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
if [ -f "$HOME/dotfiles/config/.dotfiles_env" ]; then
    source "$HOME/dotfiles/config/.dotfiles_env"
fi
# End Dotfiles Environment Setup
EOF
    info "added source lines to ~/.zshrc"
else
    warn "dotfiles source lines already in ~/.zshrc, skipping"
fi
echo ""

# 4. Symlink tmux.conf
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
info "~/.tmux.conf -> dotfiles/tmux/tmux.conf"

# 5. Symlink nvim config
mkdir -p "$HOME/.config"
rm -rf "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
info "~/.config/nvim -> dotfiles/nvim"

# 6. Symlink Claude Code configs
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
info "~/.claude/CLAUDE.md -> dotfiles/claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
info "~/.claude/settings.json -> dotfiles/claude/settings.json"

# 7. Symlink skills
mkdir -p "$HOME/.claude/skills"
ln -sf "$DOTFILES_DIR/skills/granola-sync" "$HOME/.claude/skills/granola-sync"
info "~/.claude/skills/granola-sync -> dotfiles/skills/granola-sync"
ln -sf "$DOTFILES_DIR/skills/granola-latest" "$HOME/.claude/skills/granola-latest"
info "~/.claude/skills/granola-latest -> dotfiles/skills/granola-latest"
ln -sf "$DOTFILES_DIR/skills/edit-copy" "$HOME/.claude/skills/edit-copy"
info "~/.claude/skills/edit-copy -> dotfiles/skills/edit-copy"
ln -sf "$DOTFILES_DIR/skills/new-blog-post" "$HOME/.claude/skills/new-blog-post"
info "~/.claude/skills/new-blog-post -> dotfiles/skills/new-blog-post"
ln -sf "$DOTFILES_DIR/skills/new-project" "$HOME/.claude/skills/new-project"
info "~/.claude/skills/new-project -> dotfiles/skills/new-project"
ln -sf "$DOTFILES_DIR/skills/plan-tickets" "$HOME/.claude/skills/plan-tickets"
info "~/.claude/skills/plan-tickets -> dotfiles/skills/plan-tickets"
ln -sf "$DOTFILES_DIR/skills/execute-tickets" "$HOME/.claude/skills/execute-tickets"
info "~/.claude/skills/execute-tickets -> dotfiles/skills/execute-tickets"
ln -sf "$DOTFILES_DIR/skills/weekly-planning" "$HOME/.claude/skills/weekly-planning"
info "~/.claude/skills/weekly-planning -> dotfiles/skills/weekly-planning"
ln -sf "$DOTFILES_DIR/skills/morning" "$HOME/.claude/skills/morning"
info "~/.claude/skills/morning -> dotfiles/skills/morning"
ln -sf "$DOTFILES_DIR/skills/evening" "$HOME/.claude/skills/evening"
info "~/.claude/skills/evening -> dotfiles/skills/evening"
ln -sf "$DOTFILES_DIR/skills/wrap-up" "$HOME/.claude/skills/wrap-up"
info "~/.claude/skills/wrap-up -> dotfiles/skills/wrap-up"
ln -sf "$DOTFILES_DIR/skills/prep" "$HOME/.claude/skills/prep"
info "~/.claude/skills/prep -> dotfiles/skills/prep"
ln -sf "$DOTFILES_DIR/skills/process" "$HOME/.claude/skills/process"
info "~/.claude/skills/process -> dotfiles/skills/process"
ln -sf "$DOTFILES_DIR/skills/save-context" "$HOME/.claude/skills/save-context"
info "~/.claude/skills/save-context -> dotfiles/skills/save-context"
echo ""

# 8. Register MCP servers in ~/.claude.json
# (Note: Cloud plugins — Granola, Linear — are managed via Claude.ai account)
echo "Configuring MCP servers..."
if command -v claude &>/dev/null; then
    # Todoist (hosted HTTP server — no local deps)
    if [ -f "$HOME/.claude.json" ] && grep -q '"todoist"' "$HOME/.claude.json" 2>/dev/null; then
        info "todoist MCP already registered"
    else
        claude mcp add --transport http todoist https://ai.todoist.net/mcp 2>/dev/null && \
            info "todoist MCP registered" || \
            warn "could not register todoist MCP (run manually: claude mcp add --transport http todoist https://ai.todoist.net/mcp)"
    fi

    # Google Calendar (stdio server via npx — requires GCP OAuth credentials)
    if [ -f "$HOME/.claude.json" ] && grep -q '"google-calendar"' "$HOME/.claude.json" 2>/dev/null; then
        info "google-calendar MCP already registered"
    else
        warn "google-calendar MCP not registered"
        echo "  To set up Google Calendar, you need GCP OAuth credentials:"
        echo "  1. Create OAuth credentials at https://console.cloud.google.com"
        echo "  2. Save the JSON file (e.g. ~/config/gcp-oauth.keys.json)"
        echo "  3. Run: claude mcp add -e GOOGLE_OAUTH_CREDENTIALS=/path/to/credentials.json google-calendar npx @cocal/google-calendar-mcp"
    fi

    # qmd (local file search — BM25 + vector + LLM re-ranking via npx)
    if [ -f "$HOME/.claude.json" ] && grep -q '"qmd"' "$HOME/.claude.json" 2>/dev/null; then
        info "qmd MCP already registered"
    else
        claude mcp add qmd -- npx @tobilu/qmd mcp 2>/dev/null && \
            info "qmd MCP registered" || \
            warn "could not register qmd MCP (run manually: claude mcp add qmd -- npx @tobilu/qmd mcp)"
    fi

    # qmd collections (per-machine index state in ~/.cache/qmd/)
    if npx @tobilu/qmd collection list 2>/dev/null | grep -q "tars-vault"; then
        info "qmd collection 'tars-vault' already exists"
    else
        if [ -d "$HOME/tars-vault" ]; then
            npx @tobilu/qmd collection add "$HOME/tars-vault" --name tars-vault --mask "**/*.md" 2>/dev/null && \
                npx @tobilu/qmd embed 2>/dev/null && \
                info "qmd collection 'tars-vault' created and embedded" || \
                warn "could not create qmd collection (run manually: npx @tobilu/qmd collection add ~/tars-vault --name tars-vault --mask '**/*.md' && npx @tobilu/qmd embed)"
        else
            warn "~/tars-vault not found — skipping qmd collection setup"
            echo "  After cloning tars-vault, run:"
            echo "  npx @tobilu/qmd collection add ~/tars-vault --name tars-vault --mask '**/*.md'"
            echo "  npx @tobilu/qmd embed"
        fi
    fi

    # Check which servers need OAuth authentication
    echo ""
    echo "MCP OAuth status:"
    needs_auth=false
    for server in todoist google-calendar; do
        if [ -f "$HOME/.claude.json" ] && grep -q "\"$server\"" "$HOME/.claude.json" 2>/dev/null; then
            echo "  - $server: registered (authenticate via: claude → /mcp → $server → OAuth)"
            needs_auth=true
        fi
    done
    echo "  - granola, linear: managed via Claude.ai cloud account (auto-available when logged in)"
    if [ "$needs_auth" = true ]; then
        warn "Local MCP servers require browser OAuth on first use per machine"
    fi
else
    warn "claude CLI not found — skipping MCP server setup"
    echo "  Install Claude Code, then re-run this script or manually add MCP servers:"
    echo "  claude mcp add --transport http todoist https://ai.todoist.net/mcp"
fi
echo ""

# 10. Validate
echo "Validating..."
all_good=true
for f in "$DOTFILES_DIR/shell/exports.zsh" "$DOTFILES_DIR/shell/aliases.zsh" \
         "$DOTFILES_DIR/shell/functions.zsh" "$DOTFILES_DIR/shell/welcome.zsh" \
         "$DOTFILES_DIR/config/ascii-art.txt" "$DOTFILES_DIR/tmux/tmux.conf" \
         "$DOTFILES_DIR/nvim/init.lua" "$DOTFILES_DIR/claude/CLAUDE.md" \
         "$DOTFILES_DIR/claude/settings.json"; do
    if [ -f "$f" ]; then
        info "$(basename $f) exists"
    else
        fail "$(basename $f) missing"
        all_good=false
    fi
done

for link in "$HOME/.tmux.conf" "$HOME/.config/nvim" "$HOME/.claude/CLAUDE.md" \
            "$HOME/.claude/settings.json" "$HOME/.claude/skills/granola-sync" \
            "$HOME/.claude/skills/granola-latest" "$HOME/.claude/skills/edit-copy" \
            "$HOME/.claude/skills/new-blog-post" "$HOME/.claude/skills/new-project" \
            "$HOME/.claude/skills/plan-tickets" "$HOME/.claude/skills/execute-tickets" \
            "$HOME/.claude/skills/weekly-planning" "$HOME/.claude/skills/morning" \
            "$HOME/.claude/skills/evening" "$HOME/.claude/skills/wrap-up" \
            "$HOME/.claude/skills/prep" "$HOME/.claude/skills/process" \
            "$HOME/.claude/skills/save-context"; do
    if [ -L "$link" ]; then
        info "symlink $(basename $link) ok"
    else
        fail "symlink $(basename $link) broken or missing"
        all_good=false
    fi
done
echo ""

# 11. Prompt for .dotfiles_env
if [ ! -f "$DOTFILES_DIR/config/.dotfiles_env" ]; then
    warn ".dotfiles_env not found"
    echo "  Copy the example and fill in your keys:"
    echo "  cp $DOTFILES_DIR/config/.dotfiles_env.example $DOTFILES_DIR/config/.dotfiles_env"
    echo ""
fi

# 12. Done
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. source ~/.zshrc"
echo "  2. Set up .dotfiles_env with your API keys (if not done)"
echo "  3. Open tmux: tmux new -s dev"
echo "  4. Open nvim inside tmux to test Ctrl+h/j/k/l navigation"
echo "  5. MCP servers: authenticate local servers via browser on first use"
echo "     run 'claude' → /mcp → select server → complete OAuth"
echo ""
