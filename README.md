# Dotfiles

Portable dev environment: zsh + tmux + nvim + Claude Code.

## What's included

- **Shell** — modular zsh config (exports, aliases, functions, welcome banner)
- **tmux** — sensible defaults, `Ctrl-a` prefix, vim-tmux-navigator integration
- **Neovim** — minimal `init.lua` with lazy.nvim and vim-tmux-navigator
- **Claude Code** — user-level `CLAUDE.md`, settings (tmux teammate mode), and custom skills
- **Secrets** — per-machine `.dotfiles_env` file (gitignored)

## Requirements

- macOS
- zsh + Oh My Zsh
- git
- [tmux](https://github.com/tmux/tmux) (`brew install tmux`)
- [Neovim](https://neovim.io/) (`brew install neovim`)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (optional)

## Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash .install.sh
```

The install script will:
1. Back up existing configs
2. Add source lines to `~/.zshrc`
3. Symlink tmux, nvim, and Claude Code configs
4. Prompt you to set up API keys in `config/.dotfiles_env`

## Secrets

Copy the example and fill in your keys:

```bash
cp config/.dotfiles_env.example config/.dotfiles_env
```

This file is gitignored and never committed.
