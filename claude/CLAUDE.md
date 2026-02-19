# Andrew Getz

## Environment
- Shell: Zsh (Oh My Zsh)
- Editor: Neovim
- Terminal multiplexer: tmux
- Package manager: Homebrew
- Dotfiles: ~/dotfiles

## MCP Servers

MCP servers are configured in `~/.claude.json` (machine-specific, not in dotfiles) via `claude mcp add` or the install script. Cloud plugins are managed through the Claude.ai account.

**Cloud plugins** (via Claude.ai account — automatic on any machine logged into the same account):
- **Granola** — meeting notes, transcripts, and queries
- **Linear** — issue tracking and project management

**Local servers** (registered in `~/.claude.json` — set up per machine by `.install.sh`):
- **Google Calendar** (`@cocal/google-calendar-mcp` via stdio) — events, free/busy, RSVP. Requires GCP OAuth credentials file.
- **Todoist** (`https://ai.todoist.net/mcp` via HTTP) — task management (create, read, update, complete tasks and projects)
- **qmd** (`@tobilu/qmd` via stdio) — local file search with BM25 keyword search, vector semantic search, and LLM re-ranking. Collections configured per-machine via `qmd collection add`.

All servers use browser OAuth (except qmd — no auth needed). Authenticate each on first use per machine: `claude` → `/mcp` → select server → complete OAuth.

**Note:** `settings.json` is for behavior settings only (permissions, env vars). MCP servers do NOT go in `settings.json` — they are silently ignored there.

## Preferences
<!-- Add preferences here as you discover them -->
