#!/bin/bash
# Claude Code notification hook
# Sends a macOS notification when Claude needs user input

input=$(cat)
notification_type=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('notification_type',''))" 2>/dev/null)

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

osascript -e "display notification \"$msg\" with title \"Claude Code\" sound name \"Glass\""
