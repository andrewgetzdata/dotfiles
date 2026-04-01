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
for f in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.tmux.conf" "$HOME/.gitconfig"; do
    [ -f "$f" ] && cp "$f" "$BACKUP_DIR/" && info "backed up $(basename $f)"
done
[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim" && info "backed up nvim config"
[ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" "$BACKUP_DIR/" && info "backed up CLAUDE.md"
[ -f "$HOME/.claude/settings.json" ] && cp "$HOME/.claude/settings.json" "$BACKUP_DIR/settings.json.bak" && info "backed up settings.json"
echo "Backups in: $BACKUP_DIR"
echo ""

# 3. Symlink shell configs
echo "Configuring shell..."
ln -sf "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
info "~/.zshrc -> dotfiles/shell/zshrc"
ln -sf "$DOTFILES_DIR/shell/zprofile" "$HOME/.zprofile"
info "~/.zprofile -> dotfiles/shell/zprofile"
echo ""

# 4. Install Homebrew packages (if Brewfile exists and brew is available)
if [ -f "$DOTFILES_DIR/Brewfile" ] && command -v brew &>/dev/null; then
    echo "Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock 2>/dev/null && \
        info "Brewfile packages installed" || \
        warn "some Brewfile packages failed (run manually: brew bundle --file=$DOTFILES_DIR/Brewfile)"
    echo ""
fi

# 5. Symlink tmux.conf
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
info "~/.tmux.conf -> dotfiles/tmux/tmux.conf"

# 6. Symlink gitconfig
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
info "~/.gitconfig -> dotfiles/git/gitconfig"

# 7. Symlink nvim config
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

# 7. Symlink skills (auto-discovers all skill directories)
mkdir -p "$HOME/.claude/skills"
skill_count=0
for skill_dir in "$DOTFILES_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    [ -f "$skill_dir/SKILL.md" ] || { warn "skills/$skill_name has no SKILL.md, skipping"; continue; }

    # Create self-referencing symlink inside skill dir (required for Claude Code discovery)
    if [ ! -L "$skill_dir/$skill_name" ]; then
        ln -sf "$skill_dir" "$skill_dir/$skill_name"
        info "created self-ref symlink for $skill_name"
    fi

    # Symlink skill into ~/.claude/skills/
    ln -sf "$skill_dir" "$HOME/.claude/skills/$skill_name"
    skill_count=$((skill_count + 1))
done
info "linked $skill_count skills to ~/.claude/skills/"
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
for f in "$DOTFILES_DIR/shell/zshrc" "$DOTFILES_DIR/shell/zprofile" \
         "$DOTFILES_DIR/shell/exports.zsh" "$DOTFILES_DIR/shell/aliases.zsh" \
         "$DOTFILES_DIR/shell/functions.zsh" "$DOTFILES_DIR/shell/welcome.zsh" \
         "$DOTFILES_DIR/config/ascii-art.txt" "$DOTFILES_DIR/tmux/tmux.conf" \
         "$DOTFILES_DIR/nvim/init.lua" "$DOTFILES_DIR/git/gitconfig" \
         "$DOTFILES_DIR/claude/CLAUDE.md" \
         "$DOTFILES_DIR/claude/settings.json"; do
    if [ -f "$f" ]; then
        info "$(basename $f) exists"
    else
        fail "$(basename $f) missing"
        all_good=false
    fi
done

for link in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.tmux.conf" \
            "$HOME/.gitconfig" "$HOME/.config/nvim" \
            "$HOME/.claude/CLAUDE.md" "$HOME/.claude/settings.json"; do
    if [ -L "$link" ]; then
        info "symlink $(basename $link) ok"
    else
        fail "symlink $(basename $link) broken or missing"
        all_good=false
    fi
done

# Validate skill symlinks dynamically
for skill_dir in "$DOTFILES_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    [ -f "$skill_dir/SKILL.md" ] || continue
    if [ -L "$HOME/.claude/skills/$skill_name" ]; then
        info "skill $skill_name ok"
    else
        fail "skill $skill_name symlink broken or missing"
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
