#!/bin/bash
# Claude Code Stop hook — append a breadcrumb line to the daily session log
# Debounced: only writes if >10 minutes since last write
# Zero Claude tokens: pure shell + git status
#
# Appends to: ~/fountain-obsidian/daily/sessions.log

VAULT="$HOME/fountain-obsidian"
LOG="$VAULT/daily/sessions.log"
LOCKFILE="/tmp/.claude-breadcrumb-last"

# Debounce: skip if <600s since last write
LAST=$(cat "$LOCKFILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
DELTA=$((NOW - LAST))
if [ "$DELTA" -lt 600 ]; then
    exit 0
fi
echo "$NOW" > "$LOCKFILE"

# Read hook payload
input=$(cat)
cwd=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)
sid=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','')[:8])" 2>/dev/null)

# Get dirty files from git
dirty=""
if [ -n "$cwd" ] && [ -d "$cwd/.git" ]; then
    dirty=$(cd "$cwd" && git diff --name-only HEAD 2>/dev/null | head -5 | tr '\n' ',' | sed 's/,$//')
fi

project=$(basename "$cwd" 2>/dev/null)
ts=$(date -Iseconds)

echo "$ts | $sid | $project | $dirty" >> "$LOG"

exit 0
