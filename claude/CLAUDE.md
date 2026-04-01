# Andrew Getz

## Environment
- Shell: Zsh (Oh My Zsh)
- Editor: Neovim
- Terminal multiplexer: tmux
- Package manager: Homebrew
- Dotfiles: ~/dotfiles

## MCP Servers

MCP servers are configured in `~/.claude.json` (machine-specific, not in dotfiles) via `claude mcp add` or the install script. Cloud plugins are managed through the Claude.ai account.

**Cloud plugins** (via Claude.ai account — automatic on any machine logged into the same account):
- **Granola** — meeting notes, transcripts, and queries
- **Linear** — issue tracking and project management

**Local servers** (registered in `~/.claude.json` — set up per machine by `.install.sh`):
- **Google Calendar** (`@cocal/google-calendar-mcp` via stdio) — events, free/busy, RSVP. Requires GCP OAuth credentials file.
- **Todoist** (`https://ai.todoist.net/mcp` via HTTP) — task management (create, read, update, complete tasks and projects)
- **qmd** (`@tobilu/qmd` via stdio) — local file search with BM25 keyword search, vector semantic search, and LLM re-ranking. Collections configured per-machine via `qmd collection add`.

All servers use browser OAuth (except qmd — no auth needed). Authenticate each on first use per machine: `claude` → `/mcp` → select server → complete OAuth.

**Note:** `settings.json` is for behavior settings only (permissions, env vars). MCP servers do NOT go in `settings.json` — they are silently ignored there.

## Linear Projects
- **Context Engine**: `b52b3db4-2e01-460b-bcca-61c6ca27d7ab` (DAT team)

## Preferences

### Tech Stack
- **Python** (3.10+): FastAPI, Dagster, pandas/polars, scikit-learn, PyTorch, Pydantic
- **TypeScript/JavaScript**: React, Astro, Next.js, Vite, Radix UI, TanStack Query
- **Styling**: Tailwind CSS
- **Databases**: DuckDB, PostgreSQL, SQLite, LanceDB (vector search)
- **Python packaging**: pyproject.toml (hatchling/poetry/setuptools), uv/pip
- **Node packaging**: npm or pnpm
- **Code quality**: black + ruff (Python), eslint + prettier (JS/TS), mypy
- **Testing**: pytest (Python), vitest (JS/TS)
- **CI/CD**: GitHub Actions
- **Containerization**: Docker

### Coding Principles
- Readability over cleverness; don't optimize prematurely
- Type safety everywhere (Pydantic, TypeScript strict, mypy)
- Validate at system boundaries, trust internal code
- DRY when there's real repetition — three similar lines beats a premature abstraction
- Comments only for the "why", never restate what code does
- Local-first data when possible (DuckDB, SQLite, JSON)

### Git
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Feature branches (`feat/*`, `fix/*`) off main, rebase over merge

### Communication
- Be concise — lead with the answer, skip preamble
- Don't summarize what you just did
- Show code over explanation when possible
- Skip emojis unless asked
- Use tabs for nested list items in Markdown

### Style Guides
For detailed coding patterns, project structure, and testing conventions, read the relevant doc from `~/dotfiles/docs/` before writing code:
- `docs/python.md` — Python style, patterns, project structure
- `docs/typescript.md` — TypeScript/React style and patterns
- `docs/testing.md` — testing philosophy, fixtures, naming conventions
