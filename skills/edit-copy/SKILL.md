---
name: edit-copy
description: Edit and improve writing for clarity, tone, and correctness. Use for copywriting, proofreading, and editorial review of blog posts, project descriptions, or any site content.
argument-hint: [file-path-or-topic]
---

Review and edit the content at `$ARGUMENTS` for quality, clarity, and consistency.

## Editorial Process

1. **Read the content** — understand the intent and audience.

2. **Check for issues** in this order:
   - **Spelling & grammar** — fix typos, subject-verb agreement, punctuation
   - **Clarity** — simplify complex sentences, remove jargon, ensure ideas flow logically
   - **Conciseness** — cut filler words, redundant phrases, and unnecessary qualifiers
   - **Voice consistency** — match the site's tone: conversational, professional, first-person
   - **Technical accuracy** — verify code references, tool names, and technical claims
   - **Formatting** — proper Markdown headings, lists, code blocks, bold/italic usage

3. **Site voice guidelines**:
   - First person, conversational but professional
   - Favor clarity over cleverness
   - Short paragraphs (2-4 sentences)
   - Use bold for key terms on first mention
   - Avoid buzzwords and excessive jargon
   - End sections with clear takeaways
   - Lowercase headings match the site's aesthetic

4. **Structural review**:
   - Does the opening hook the reader?
   - Do headings create a scannable outline?
   - Is there a clear beginning, middle, and conclusion?
   - Are code examples explained with context?
   - Does the piece deliver on its title/description promise?

5. **SEO check**:
   - Does the `description` frontmatter field accurately summarize the content?
   - Are `tags` relevant and consistent with existing tags on the site?
   - Is the title clear and descriptive?

6. **Present changes** — show a summary of edits made, grouped by category (grammar, clarity, structure, etc.). For substantial rewrites, explain the reasoning.

## Quick Mode

If the argument is a short phrase or sentence rather than a file path, treat it as inline copy to edit. Return the improved version with brief notes on what changed.
