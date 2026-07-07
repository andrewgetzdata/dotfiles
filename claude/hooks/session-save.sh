#!/bin/bash
# Claude Code SessionEnd hook — write session summary to Obsidian vault
# Zero Claude tokens: parses transcript_path JSON directly with Python
#
# Writes: ~/fountain-obsidian/daily/sessions/YYYY-MM-DD-HHMM-<sid>.md

SESSIONS_DIR="$HOME/fountain-obsidian/daily/sessions"
mkdir -p "$SESSIONS_DIR"

# Pass stdin (hook JSON payload) + sessions dir to Python
SESSIONS_DIR="$SESSIONS_DIR" python3 "$HOME/dotfiles/claude/hooks/session-save.py"

exit 0
