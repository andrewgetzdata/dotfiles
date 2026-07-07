"""
Parse Claude Code hook payload + transcript, write a session summary to Obsidian.

Reads JSON from stdin (hook payload with session_id, cwd, transcript_path).
Parses the transcript file to extract files modified, tools used, and task summaries.
Writes a structured markdown note to ~/fountain-obsidian/daily/sessions/.

Zero Claude tokens — pure file parsing.
"""

import json
import os
import sys
from collections import Counter
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
    cwd = payload.get("cwd", "")
    transcript_path = payload.get("transcript_path", "")

    if not transcript_path or not os.path.exists(transcript_path):
        return

    # Parse transcript (JSONL: one JSON object per line)
    messages = []
    try:
        with open(transcript_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    messages.append(entry)
                except json.JSONDecodeError:
                    continue
    except Exception:
        return

    files_modified = set()
    tools_used = Counter()
    user_messages = 0
    assistant_messages = 0
    task_summaries = []

    for entry in messages:
        # JSONL entries: role is entry["type"], content is entry["message"]["content"]
        role = entry.get("type", entry.get("role", ""))
        msg_obj = entry.get("message", entry)
        content = msg_obj.get("content", "")

        if role == "user":
            user_messages += 1
            # Skip compaction summaries and system injections
            if entry.get("isCompactSummary") or entry.get("isVisibleInTranscriptOnly"):
                continue
            if isinstance(content, str) and len(content) > 15:
                # Skip system/command messages
                if content.startswith("<") or content.startswith("{"):
                    continue
                first_line = content.strip().split("\n")[0][:120]
                if len(first_line) > 15:
                    task_summaries.append(first_line)

        elif role == "assistant":
            assistant_messages += 1
            if not isinstance(content, list):
                continue
            for block in content:
                if not isinstance(block, dict):
                    continue
                # Track tool usage
                tool_name = block.get("name", block.get("tool_name", ""))
                if tool_name:
                    tools_used[tool_name] += 1
                # Extract file paths from tool inputs
                tool_input = block.get("input", {})
                if not isinstance(tool_input, dict):
                    continue
                for key in ("file_path", "path"):
                    fp = tool_input.get(key, "")
                    if fp and not fp.startswith("/tmp"):
                        files_modified.add(fp)

    # Deduplicate task summaries
    seen = set()
    unique_tasks = []
    for t in task_summaries:
        key = t[:40].lower()
        if key not in seen:
            seen.add(key)
            unique_tasks.append(t)
        if len(unique_tasks) >= 8:
            break

    # Build note
    now = datetime.now()
    sid_short = session_id[:8] if session_id != "unknown" else "unknown"
    project = os.path.basename(cwd) if cwd else "unknown"
    top_tools = [name for name, _ in tools_used.most_common(10)]
    clean_files = sorted(files_modified)[:25]

    tasks_block = "\n".join(f"- {t}" for t in unique_tasks) if unique_tasks else "- (none captured)"
    tools_block = ", ".join(top_tools) if top_tools else "(none)"
    files_block = "\n".join(f"- `{f}`" for f in clean_files) if clean_files else "- (none)"

    note = f"""---
date: {now.strftime('%Y-%m-%d')}
session_id: {session_id}
project: {project}
cwd: {cwd}
tags:
  - session
---

# Session {sid_short} — {now.strftime('%Y-%m-%d %H:%M')}

**Project:** {project}
**Messages:** {user_messages} user / {assistant_messages} assistant

## Tasks
{tasks_block}

## Tools Used
{tools_block}

## Files Modified
{files_block}
"""

    filename = f"{now.strftime('%Y-%m-%d-%H%M')}-{sid_short}.md"
    filepath = os.path.join(sessions_dir, filename)

    with open(filepath, "w") as f:
        f.write(note.strip() + "\n")


if __name__ == "__main__":
    main()
