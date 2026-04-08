#!/bin/bash
# Claude Code notification hook
# Sends a macOS notification when Claude needs user input

input=$(cat)
eval "$(echo "$input" | python3 -c "
import sys, json, os
d = json.load(sys.stdin)
print(f'notification_type={d.get(\"notification_type\", \"\")}')
print(f'cwd={d.get(\"cwd\", \"\")}')
print(f'session_id={d.get(\"session_id\", \"\")}')
" 2>/dev/null)"

project=$(basename "$cwd")

case "$notification_type" in
  permission_prompt)
    msg="Waiting for permission approval"
    ;;
  idle_prompt)
    msg="Finished and waiting for input"
    ;;
  elicitation_dialog)
    msg="Needs additional information"
    ;;
  *)
    msg="Needs your attention"
    ;;
esac

icon="$(dirname "$0")/claude-icon.png"

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$project" \
  -message "$msg" \
  -contentImage "$icon" \
  -sound Glass
