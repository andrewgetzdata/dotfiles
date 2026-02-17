---
name: new-project
description: Create a new project/work entry with proper frontmatter, schema validation, and site integration. Use when adding a project case study or work showcase.
argument-hint: [project-title]
---

Create a new project entry titled "$ARGUMENTS".

## Steps

1. **Generate the slug** from the title (lowercase, hyphens, no special characters).

2. **Create the file** at `src/content/projects/<slug>.md` with this frontmatter:

```yaml
---
title: "$ARGUMENTS"
description: "<brief 1-2 sentence description>"
startDate: <YYYY-MM-DD>
endDate: <YYYY-MM-DD or omit if ongoing>
status: "completed"     # completed | in-progress | planned | archived
featured: false
category: "data-analysis"  # data-analysis | web-development | automation | content
tags: [<general tags>]
technologies: [<tech stack used>]
type: "work"            # or "writing"
view_source: "<optional: URL to source code>"
github: "<optional: repo URL>"
url: "<optional: live project URL>"
client: "<optional: client name>"
image:
  src: "<optional: /images/hero.jpg>"
  alt: "<optional: image description>"
---
```

3. **Frontmatter schema reference** (from `src/content/config.ts`):
   - `title` (string, required)
   - `description` (string, required)
   - `startDate` (Date, required)
   - `endDate` (Date, optional)
   - `status` (enum: completed/in-progress/planned/archived, required)
   - `featured` (boolean, required)
   - `category` (enum: web-development/data-analysis/automation/content, required)
   - `tags` (string[], required)
   - `technologies` (string[], required)
   - `type` (string, optional)
   - `view_source` (string/URL, optional)
   - `github` (string/URL, optional)
   - `url` (string/URL, optional)
   - `client` (string, optional)
   - `image` / `gallery` (optional)

4. **Write the project body** as a case study in Markdown:
   - **Project Overview** — what and why
   - **Technical Implementation** — how it was built, key decisions
   - **Results / Impact** — outcomes, metrics
   - **Lessons Learned** — takeaways
   - Include code snippets where relevant

5. **Check tag/tech consistency** — read existing projects in `src/content/projects/` to reuse tags and technology names consistently.

6. **Places that may need updating**:
   - If `featured: true`, verify it shows on the homepage (`src/pages/index.astro`)
   - The blog listing page (`src/pages/work.astro`) auto-discovers types, tags, and categories from content — no manual filter updates needed
   - Project detail pages are auto-generated at `/work/<slug>/` via `src/pages/work/[...slug].astro`

7. **Badge color conventions** used on the site:
   - `badge-gray-subtle` — type (work/writing)
   - `badge-teal-subtle` — category
   - `badge-amber-subtle` — tags
   - `badge-blue-subtle` — technologies (resume only)

8. **Validate** by running `npm run build` to ensure no schema errors.
