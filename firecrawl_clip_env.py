#!/usr/bin/env python3
"""
Firecrawl URL Clipper - Environment Variable Version

Alternative version that uses environment variables instead of 1Password CLI.
Useful as a fallback when 1Password CLI integration has issues.

Usage:
  # Set environment variables first
  export FIRECRAWL_API_KEY="your_key_here"
  export ANTHROPIC_API_KEY="your_key_here"

  # Then run the script
  python firecrawl_clip_env.py <url>

Or create a .env file in the same directory with:
  FIRECRAWL_API_KEY=your_key_here
  ANTHROPIC_API_KEY=your_key_here
"""

import argparse
import os
import re
import sys
from datetime import date
from pathlib import Path

import requests

# Try to load .env file if it exists
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


def get_env_var(name: str) -> str:
    """Get environment variable or exit with error."""
    value = os.environ.get(name)
    if not value:
        print(f"❌ Missing environment variable: {name}")
        print(f"Set it with: export {name}='your_key_here'")
        print(f"Or add it to a .env file in this directory")
        sys.exit(1)
    return value


def scrape_with_firecrawl(url: str, api_key: str) -> tuple[str, dict]:
    """Scrape URL with Firecrawl API."""
    print(f"🔥 Scraping with Firecrawl: {url}")

    payload = {
        "url": url,
        "formats": ["markdown"],
        "onlyMainContent": True
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(
            "https://api.firecrawl.dev/v1/scrape",
            json=payload,
            headers=headers,
            timeout=60
        )
        response.raise_for_status()
        data = response.json()

        markdown = data.get("data", {}).get("markdown", "")
        metadata = data.get("data", {}).get("metadata", {})

        return markdown, metadata

    except requests.exceptions.RequestException as e:
        print(f"❌ Firecrawl API error: {e}")
        sys.exit(1)


def process_with_claude(markdown: str, api_key: str) -> dict:
    """Process markdown with Claude to extract structured content."""
    print("🤖 Processing with Claude...")

    try:
        import anthropic
        client = anthropic.Anthropic(api_key=api_key)
    except ImportError:
        print("❌ anthropic package not installed. Run: pip install anthropic")
        sys.exit(1)

    # Truncate if too long
    if len(markdown) > 100000:
        markdown = markdown[:100000] + "\n\n[... truncated for length ...]"

    system_prompt = """You are helping format and summarize a web article for a personal knowledge base.
Extract key information and clean up the content."""

    user_prompt = f"""Please analyze this article and extract the following information in this exact format:

TITLE: [article title]
AUTHOR: [author name or "Unknown"]
DESCRIPTION: [one sentence description]
TOPICS: [3-5 relevant topics, comma separated]

## Summary
[2-3 sentence summary of the main points]

## Key Concepts
- [key concept 1]
- [key concept 2]
- [key concept 3]

## Article Content
[cleaned up article content in markdown]

Here's the raw markdown to process:

{markdown}"""

    try:
        response = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=8000,
            system=system_prompt,
            messages=[{"role": "user", "content": user_prompt}]
        )

        return parse_claude_response(response.content[0].text)

    except Exception as e:
        print(f"❌ Claude API error: {e}")
        sys.exit(1)


def parse_claude_response(text: str) -> dict:
    """Parse Claude's response into structured data."""
    result = {
        "title": "Untitled",
        "author": "Unknown",
        "description": "",
        "topics": [],
        "summary": "",
        "key_concepts": "",
        "content": ""
    }

    lines = text.split('\n')
    current_section = None
    content_lines = []

    for line in lines:
        line = line.strip()

        if line.startswith("TITLE:"):
            result["title"] = line.replace("TITLE:", "").strip()
        elif line.startswith("AUTHOR:"):
            result["author"] = line.replace("AUTHOR:", "").strip()
        elif line.startswith("DESCRIPTION:"):
            result["description"] = line.replace("DESCRIPTION:", "").strip()
        elif line.startswith("TOPICS:"):
            topics_str = line.replace("TOPICS:", "").strip()
            result["topics"] = [t.strip() for t in topics_str.split(",")]
        elif line == "## Summary":
            current_section = "summary"
            content_lines = []
        elif line == "## Key Concepts":
            if current_section == "summary":
                result["summary"] = '\n'.join(content_lines).strip()
            current_section = "key_concepts"
            content_lines = []
        elif line == "## Article Content":
            if current_section == "key_concepts":
                result["key_concepts"] = '\n'.join(content_lines).strip()
            current_section = "content"
            content_lines = []
        elif current_section:
            content_lines.append(line)

    # Capture the last section
    if current_section == "content":
        result["content"] = '\n'.join(content_lines).strip()

    return result


def slugify(text: str) -> str:
    """Convert text to safe filename."""
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[-\s]+', '-', text)
    return text.strip('-').lower()[:50]


def create_clipping(url: str, processed_data: dict, metadata: dict, output_dir: Path):
    """Create Obsidian clipping file."""
    title = processed_data["title"]
    slug = slugify(title)
    filename = f"{slug}.md"
    filepath = output_dir / filename

    print(f"📝 Creating clipping: {filename}")

    # Build frontmatter
    topics_yaml = '\n'.join(f'  - "[[{topic.strip()}]]"' for topic in processed_data["topics"])

    frontmatter = f"""---
buckets:
  - "[[Clippings]]"
author:
  - "[[{processed_data['author']}]]"
url: {url}
clippedDate: {date.today().isoformat()}
publishedDate: {metadata.get('publishDate', '')}
description: {processed_data['description']}
topics:
{topics_yaml}
reviewed: false
---"""

    # Build content
    content = f"""{frontmatter}

# {title}

## Summary
{processed_data['summary']}

## Key Concepts
{processed_data['key_concepts']}

---

{processed_data['content']}
"""

    # Write file
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath.write_text(content, encoding='utf-8')

    print(f"✅ Clipping saved: {filepath}")
    return filepath


def main():
    parser = argparse.ArgumentParser(description="Clip URL with Firecrawl and Claude (env vars)")
    parser.add_argument("url", help="URL to clip")
    parser.add_argument("--output", "-o", default="./clippings", help="Output directory")
    args = parser.parse_args()

    print("🔑 Getting API keys from environment variables...")

    # Get API keys from environment
    firecrawl_key = get_env_var("FIRECRAWL_API_KEY")
    claude_key = get_env_var("ANTHROPIC_API_KEY")

    print("✅ API keys loaded")

    # Process URL
    markdown, metadata = scrape_with_firecrawl(args.url, firecrawl_key)

    if not markdown:
        print("❌ No content retrieved from URL")
        sys.exit(1)

    processed = process_with_claude(markdown, claude_key)

    # Create clipping
    output_dir = Path(args.output)
    clipping_path = create_clipping(args.url, processed, metadata, output_dir)

    print(f"\n🎉 Successfully created clipping!")
    print(f"📁 File: {clipping_path}")
    print(f"📝 Title: {processed['title']}")
    print(f"👤 Author: {processed['author']}")


if __name__ == "__main__":
    main()