# /process — Fetch + Extract Insights

Process pending clips from web_urls.json: fetch via Firecrawl, save clipping, clean, extract atomic insights, write knowledge notes, update daily processing log.

## Procedure

### 1. Read pending URLs

Read `web_urls.json`. Filter entries where `status` is "pending".
- If no pending URLs, report "Nothing to process" and stop.
- **Maximum 10 URLs per run.** If more than 10 are pending, pick 10 (prioritize variety of topics or oldest first) and leave the rest for the next run. Report how many remain.
- Separate clips from bookmarks — handle differently.

### 2. Process each clip

Loop through each clip URL **sequentially**. For each URL, run the pipeline below. Each step uses the right model for the job — the main agent orchestrates and handles all file I/O.

For each clip URL:

#### a. Fetch (main agent — Bash)

```bash
python3 ~/dotfiles/scripts/firecrawl_fetch.py "URL" --json
```

This returns JSON with `markdown` (article content) and `metadata` (title, author, description, publishedDate, etc.). If the fetch fails, mark the URL as status "error" in web_urls.json and continue to the next URL.

#### b. Clean (Haiku sub-agent)

Spawn a **Haiku** sub-agent (`model: haiku`) with the raw markdown content in the prompt. The sub-agent:
- Strips web boilerplate: navigation, footers, sidebars, cookie notices, ads, subscription prompts
- Removes excessive formatting (multiple blank lines, decorative elements)
- Preserves article structure: headings, paragraphs, code blocks, lists, images
- Returns clean markdown as its output

The sub-agent does NOT need file access — pass the raw markdown directly in the prompt and receive cleaned markdown back.

#### c. Save clipping (main agent — Write)

Save the full cleaned article to `clippings/` using the article title as filename.

**Filename**: `clippings/Article Title.md` — use the article title from metadata, cleaned for filesystem safety.

**Content** (matching second-brain clippings format):
```markdown
---
buckets:
  - "[[Clippings]]"
author:
  - "[[Author Name]]"
url: https://...
clippedDate: YYYY-MM-DDTHH:MM:SS-TZ
publishedDate: YYYY-MM-DD
description: description from metadata or one-line summary
topics:
  - "[[topic-name]]"
---

## Summary
Brief 2-3 sentence summary of the article.

### Key Concepts
- Key concept 1
- Key concept 2
- Key concept 3

---
# Full article title

[Full cleaned article content here]
```

- `author`: From Firecrawl metadata, wrapped in wiki-link syntax
- `clippedDate`: Current timestamp in ISO format with timezone
- `publishedDate`: From metadata if available, otherwise omit
- `topics`: Relevant topics as wiki-links

#### d. Extract insights (Sonnet sub-agent)

Spawn a **Sonnet** sub-agent (`model: sonnet`) with the cleaned article content in the prompt. The sub-agent:

1. Searches existing `knowledge/` for related notes using Grep and Glob — look for overlapping topics, complementary ideas, or contradictions
2. Identifies **3-8 atomic insights** — distinct ideas that stand alone. Each insight should be:
   - A single clear idea, not a summary of the whole article
   - Titled as a complete prose sentence (e.g., "DuckDB can query Parquet files directly from S3 without loading them")
   - Substantive enough to be worth its own note (100-300 words)
3. Returns a structured list of insights, each containing:
   - `filename`: lowercase-hyphenated-core-concept (3-6 words)
   - `title`: complete sentence title
   - `description`: one-line summary adding info beyond the title
   - `topics`: list of topic names
   - `body`: full note body text (100-300 words) with [[wiki-links]] to genuinely related existing notes
   - `connections`: list of existing notes that relate to this insight

The sub-agent needs Read/Grep/Glob access to search existing knowledge but does NOT need Write — it returns the insight data for the main agent to write.

#### e. Write knowledge notes (main agent — Write)

For each insight returned by the Sonnet sub-agent, create a note in `knowledge/`:

**Filename**: `knowledge/{filename}.md`

**Content**:
```markdown
---
buckets:
  - "[[distilled-knowledge]]"
description: {description}
topics:
  - "[[topic-name]]"
source_url: https://...
source_title: "Article Title"
clippedDate: YYYY-MM-DD
---

# {title}

{body}

---
Source: [Article Title](url)
```

### 3. Handle bookmarks

For bookmark-type URLs, create a minimal note in `knowledge/`:
- Fetch with Firecrawl to get metadata (title, description)
- Write a short note with `buckets: - "[[Bookmarks]]"` — no deep extraction
- Mark as processed

### 4. Update web_urls.json

For each processed URL:
- Set `status` to "processed"
- Set `title` from Firecrawl metadata
- Set `date_processed` to today's date

### 5. Update daily processing log

If the journal file already exists, **append** the "Articles Processed" section or add entries under the existing one. Don't overwrite existing content.

Format for each article entry:
```markdown
### Article Title
**Source**: [Article Title](url)
**Key takeaways**:
- First key insight — links to [[insight-note-name]]
- Second key insight — links to [[another-insight-note]]
```

### 6. Report

Print a summary:
- How many articles were processed
- How many clippings saved
- How many insight notes were created
- List of created note filenames
- Any errors encountered
- How many remain in queue
- Pointer to today's journal entry for the overview

## Model Routing

Each step uses the optimal model for cost and quality:

| Step | Model | Why |
|------|-------|-----|
| Fetch | Main agent (Opus) | Needs Bash for Firecrawl |
| Clean | **Haiku** sub-agent | Simple boilerplate removal, cheap and fast |
| Save clipping | Main agent (Opus) | Needs Write tool |
| Extract insights | **Sonnet** sub-agent | Needs judgment for insight quality + Read/Grep/Glob for knowledge search |
| Write notes | Main agent (Opus) | Needs Write tool |

**Key design principle**: Sub-agents never need Write or Bash permissions. The main agent handles all file creation and shell commands. Sub-agents receive content in their prompts and return structured results. This eliminates permission issues entirely.

## Tools Used

- Read, Write, Edit, Glob, Grep (file operations — main agent only)
- Bash (Firecrawl fetch — main agent only)
- Task with model: haiku (cleaning sub-agent — no file access needed)
- Task with model: sonnet (insight extraction sub-agent — Read/Grep/Glob only)
