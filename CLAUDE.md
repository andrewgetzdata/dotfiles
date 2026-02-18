# Dotfiles

Personal dev environment: Zsh (Oh My Zsh) + tmux + Neovim + Claude Code.

## Structure

- `shell/` — Zsh config (aliases, exports, functions, welcome message)
- `tmux/` — tmux.conf
- `nvim/` — Neovim config (init.lua + lazy-lock.json)
- `claude/` — Claude Code settings and global CLAUDE.md
- `claude-code/` — Claude Code setup script
- `skills/` — Claude Code skills (symlinked from site repo)
- `config/` — Misc config (ASCII art, .dotfiles_env)
- `.install.sh` — Full environment bootstrap script

## Conventions

- Configs are symlinked into place by `.install.sh` (e.g. `nvim/init.lua` -> `~/.config/nvim/init.lua`)
- Neovim plugins managed by lazy.nvim; pin versions in `nvim/lazy-lock.json`
- Skills are symlinks — don't inline their contents, keep them as links
- Shell files are sourced by `.zshrc` — each file should be self-contained
- Keep configs minimal and portable — avoid machine-specific paths

## Do Not

- Commit secrets, API keys, or `.env` files
- Modify `config/.dotfiles_env` (gitignored, machine-specific)
- Break the install script — test changes against `.install.sh` logic
