#!/usr/bin/env python3
"""
Firecrawl URL Fetcher: scrape a URL and output clean markdown.

Lightweight fetcher for use in knowledge pipelines. Returns raw Firecrawl
output. Formatting cleanup is handled downstream by the calling skill
(e.g. /seed spawns a subagent for cleaning).

Usage:
  python firecrawl_fetch.py <url>                    # raw scrape to stdout
  python firecrawl_fetch.py <url> -o output.md       # write to file
  python firecrawl_fetch.py <url> --fm -o output.md  # with YAML frontmatter

Environment (loaded from ~/config/.dotfiles_env):
  FIRECRAWL_API_KEY   (required)

Adapted from firecrawl_clip_env.py (dotfiles root).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from datetime import date
from pathlib import Path

import requests

# --- Environment loading ---

def load_dotfiles_env() -> None:
    """Load API keys from ~/config/.dotfiles_env."""
    env_path = Path.home() / "config" / ".dotfiles_env"
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key, value = key.strip(), value.strip()
        if key and value and key not in os.environ:
            os.environ[key] = value


def get_api_key() -> str:
    """Get Firecrawl API key or exit."""
    key = os.environ.get("FIRECRAWL_API_KEY", "")
    if not key:
        print("ERROR: FIRECRAWL_API_KEY not set.", file=sys.stderr)
        print("Add it to ~/config/.dotfiles_env or export it.", file=sys.stderr)
        sys.exit(1)
    return key


# --- Firecrawl API ---

FIRECRAWL_API_URL = "https://api.firecrawl.dev/v1/scrape"


def scrape(url: str, api_key: str) -> tuple[str, dict]:
    """Scrape URL via Firecrawl. Returns (markdown, metadata)."""
    payload = {
        "url": url,
        "formats": ["markdown"],
        "onlyMainContent": True,
    }
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    resp = requests.post(FIRECRAWL_API_URL, json=payload, headers=headers, timeout=60)
    resp.raise_for_status()
    data = resp.json()

    # Handle async job polling
    if data.get("id") and data.get("status") in ("PENDING", "processing"):
        job_id = data["id"]
        poll_url = f"https://api.firecrawl.dev/v1/scrape/{job_id}"
        for _ in range(60):
            time.sleep(2)
            r = requests.get(poll_url, headers=headers, timeout=30)
            r.raise_for_status()
            data = r.json()
            if data.get("status") == "completed" and "data" in data:
                break
            if data.get("status") == "failed":
                raise RuntimeError(data.get("error", "Scrape job failed"))
        else:
            raise RuntimeError("Scrape job timed out")

    d = data.get("data", data)
    markdown = d.get("markdown") or d.get("content") or ""
    metadata = d.get("metadata") or {}
    return markdown, metadata


# --- Output formatting ---

def build_frontmatter(url: str, metadata: dict) -> str:
    """Build YAML frontmatter from Firecrawl metadata."""
    title = metadata.get("title", "")
    author = metadata.get("author", "")
    description = metadata.get("description", "")
    published = metadata.get("publishDate", metadata.get("publishedDate", ""))

    lines = ["---"]
    lines.append(f"source_url: {url}")
    if title:
        lines.append(f"title: \"{title}\"")
    if author:
        lines.append(f"author: \"{author}\"")
    if description:
        lines.append(f"description: \"{description.replace(chr(34), chr(39))}\"")
    if published:
        lines.append(f"published_date: {str(published)[:10]}")
    lines.append(f"fetched: {date.today().isoformat()}")
    lines.append("---")
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description="Fetch URL content via Firecrawl.")
    ap.add_argument("url", help="URL to scrape")
    ap.add_argument("-o", "--output", help="Output file path (default: stdout)")
    ap.add_argument("--fm", action="store_true", help="Include YAML frontmatter")
    ap.add_argument("--json", action="store_true", dest="json_out", help="Output as JSON (markdown + metadata)")
    args = ap.parse_args()

    load_dotfiles_env()
    api_key = get_api_key()

    try:
        markdown, metadata = scrape(args.url, api_key)
    except requests.exceptions.RequestException as e:
        print(f"ERROR: Firecrawl API request failed: {e}", file=sys.stderr)
        sys.exit(1)
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    if not markdown:
        print("ERROR: No content retrieved from URL.", file=sys.stderr)
        sys.exit(1)

    # Build output
    if args.json_out:
        output = json.dumps({"markdown": markdown, "metadata": metadata}, indent=2)
    elif args.fm:
        output = build_frontmatter(args.url, metadata) + "\n\n" + markdown
    else:
        output = markdown

    # Write or print
    if args.output:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(output, encoding="utf-8")
        print(f"OK: {len(markdown)} chars -> {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
