"""
Detect conversation compaction and save the summary to Obsidian.

Fires on Stop hook. Checks transcript (JSONL) for compaction markers.
Uses a marker file per session to avoid re-saving the same compaction.
Zero Claude tokens — pure file parsing.
"""

import json
import os
import sys
from datetime import datetime


def main():
    sessions_dir = os.environ.get(
        "SESSIONS_DIR",
        os.path.expanduser("~/fountain-obsidian/daily/sessions"),
    )

    # Read hook payload from stdin
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, Exception):
        return

    session_id = payload.get("session_id", "unknown")
    transcript_path = payload.get("transcript_path", "")
    cwd = payload.get("cwd", "")

    if not transcript_path or not os.path.exists(transcript_path):
        return

    sid_short = session_id[:8] if session_id != "unknown" else "unknown"

    # Marker file tracks how many compactions we've already saved for this session
    marker_file = f"/tmp/.claude-compaction-{sid_short}"
    saved_count = 0
    if os.path.exists(marker_file):
        try:
            saved_count = int(open(marker_file).read().strip())
        except (ValueError, Exception):
            saved_count = 0

    # Parse JSONL transcript — one JSON object per line
    compactions = []
    try:
        with open(transcript_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Use the isCompactSummary flag (most reliable)
                if entry.get("isCompactSummary"):
                    # Content lives under entry["message"]["content"]
                    content = ""
                    msg = entry.get("message", {})
                    if isinstance(msg, dict):
                        content = msg.get("content", "")
                    if isinstance(content, list):
                        # Extract text from content blocks
                        parts = []
                        for block in content:
                            if isinstance(block, dict) and block.get("text"):
                                parts.append(block["text"])
                        content = "\n".join(parts)
                    if content:
                        compactions.append(content)
    except Exception:
        return

    if len(compactions) <= saved_count:
        return  # No new compactions

    # Save only new compactions
    new_compactions = compactions[saved_count:]
    project = os.path.basename(cwd) if cwd else "unknown"

    for i, summary in enumerate(new_compactions):
        now = datetime.now()
        idx = saved_count + i + 1

        note = f"""---
date: {now.strftime('%Y-%m-%d')}
session_id: {session_id}
project: {project}
compaction_number: {idx}
tags:
  - session
  - compaction
---

# Compaction {idx} — Session {sid_short} — {now.strftime('%Y-%m-%d %H:%M')}

**Project:** {project}

## Summary

{summary}
"""

        filename = f"compaction-{now.strftime('%Y-%m-%d-%H%M')}-{sid_short}-{idx}.md"
        filepath = os.path.join(sessions_dir, filename)

        with open(filepath, "w") as f:
            f.write(note.strip() + "\n")

    # Update marker so we don't re-save these
    with open(marker_file, "w") as f:
        f.write(str(len(compactions)))


if __name__ == "__main__":
    main()
