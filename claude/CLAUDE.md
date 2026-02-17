# Andrew Getz

## Environment
- Shell: Zsh (Oh My Zsh)
- Editor: Neovim
- Terminal multiplexer: tmux
- Package manager: Homebrew
- Dotfiles: ~/dotfiles

## MCP Servers

Two MCP servers are configured in `settings.json` (symlinked to `~/.claude/settings.json`):

- **Granola** (`https://mcp.granola.ai/mcp`) — meeting notes, transcripts, and queries. Uses browser OAuth; no API key needed. Authenticate on first use per machine.
- **Google Calendar** (`https://mcp.googleapis.com/calendar`) — list/create/update/delete events, free/busy queries, RSVP. Uses browser OAuth; no API key needed. Authenticate on first use per machine.

Both are also available as Claude.ai cloud plugins (account-managed). The local configs in `settings.json` are fallbacks for machines with a different Claude account.

## Preferences
<!-- Add preferences here as you discover them -->
