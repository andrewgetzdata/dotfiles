#!/bin/bash
# Claude Code Stop hook — save compaction summaries to Obsidian vault
# Detects conversation compaction and saves the summary before it's lost
# Zero Claude tokens: parses transcript JSON directly with Python
#
# Writes: ~/fountain-obsidian/daily/sessions/compaction-YYYY-MM-DD-HHMM-<sid>-N.md

SESSIONS_DIR="$HOME/fountain-obsidian/daily/sessions"
mkdir -p "$SESSIONS_DIR"

SESSIONS_DIR="$SESSIONS_DIR" python3 "$HOME/dotfiles/claude/hooks/compaction-save.py"

exit 0
