---
name: new-blog-post
description: Create a new blog post with proper frontmatter, schema validation, and site integration. Use when adding writing or blog content to the site.
argument-hint: [title]
---

Create a new blog post titled "$ARGUMENTS".

## Steps

1. **Generate the slug** from the title (lowercase, hyphens, no special characters).

2. **Create the file** at `src/content/blog/<slug>.md` with this frontmatter:

```yaml
---
title: "$ARGUMENTS"
description: "<2-3 sentence summary>"
pubDate: <today's date as YYYY-MM-DD>
tags: [<relevant tags>]
featured: false
draft: false
type: "writing"         # or "work" if it's a technical project writeup
category: "<optional: content, data-analysis, web-development, automation>"
view_source: "<optional: URL to source code>"
---
```

3. **Frontmatter schema reference** (from `src/content/config.ts`):
   - `title` (string, required)
   - `description` (string, required)
   - `pubDate` (Date, required)
   - `updatedDate` (Date, optional)
   - `tags` (string[], required)
   - `featured` (boolean, default false)
   - `draft` (boolean, default false)
   - `author` (string, default "Andrew Getz")
   - `type` (string, optional - "writing" or "work")
   - `category` (string, optional)
   - `view_source` (string/URL, optional)
   - `image` (object with `src` and `alt`, optional)

4. **Write the post body** in Markdown:
   - Target 800-2000 words
   - Use H2 (`##`) for main sections, H3 (`###`) for subsections
   - Include code examples with proper syntax highlighting when relevant
   - Voice: conversational but professional, avoid jargon
   - End with a conclusion or takeaway

5. **Check tag consistency** — read existing posts in `src/content/blog/` to reuse existing tags where appropriate rather than creating new ones.

6. **Places that may need updating**:
   - If `featured: true`, verify it appears on the homepage (`src/pages/index.astro`) in the featured section
   - If adding a new `type` value, check that the filter buttons on `src/pages/work.astro` will pick it up (they auto-populate from content)
   - If adding a new `category`, it will auto-appear in filters

7. **Validate** by running `npm run build` to ensure no schema errors.

## Writing Style Guide

- Write in first person
- Focus on practical insights over theory
- Use short paragraphs and clear headings
- Include "what I learned" or actionable takeaways
- Bold key terms on first use
- Keep sentences concise — favor clarity over cleverness
