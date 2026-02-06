#!/bin/bash

# Claude Code Environment Setup Script
# This script automates the initial setup for a powerful Claude Code development environment

set -e  # Exit on error

echo "🚀 Claude Code Expert Environment Setup"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Claude Code is installed
check_claude_installed() {
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓${NC} Claude Code is already installed"
        claude --version
        return 0
    else
        echo -e "${YELLOW}!${NC} Claude Code not found"
        return 1
    fi
}

# Install Claude Code
install_claude() {
    echo ""
    echo "📦 Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    if check_claude_installed; then
        echo -e "${GREEN}✓${NC} Claude Code installed successfully"
    else
        echo -e "${RED}✗${NC} Failed to install Claude Code"
        exit 1
    fi
}

# Create project structure
create_project_structure() {
    echo ""
    echo "📁 Creating project structure..."
    
    # Create directories
    mkdir -p .claude/{agents,commands,hooks}
    mkdir -p .github/workflows
    mkdir -p {src,tests,docs}
    
    echo -e "${GREEN}✓${NC} Project structure created"
}

# Create sub-agent files
create_subagents() {
    echo ""
    echo "🤖 Creating sub-agents..."
    
    # Architect sub-agent
    cat > .claude/agents/architect.md << 'EOF'
---
name: architect
description: Reviews architecture and design decisions, validates against best practices
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
---

You are a senior software architect focused on system design and best practices.

## Your Responsibilities:
1. Review proposed changes for architectural soundness
2. Check for design pattern compliance
3. Validate performance implications
4. Ensure scalability considerations
5. Document architectural decisions (ADRs)

## Guidelines:
- Consider long-term maintainability
- Flag potential technical debt
- Suggest alternative approaches when appropriate
- Focus on separation of concerns
- Validate against project conventions in CLAUDE.md

## Output Format:
Provide your review as:
- **Assessment**: Overall architectural soundness (✅ Approved / ⚠️ Needs Review / ❌ Blocked)
- **Findings**: List specific issues or concerns
- **Recommendations**: Concrete suggestions for improvement
- **ADR**: Architectural Decision Record if needed
EOF

    # Tester sub-agent
    cat > .claude/agents/tester.md << 'EOF'
---
name: tester
description: Generates comprehensive tests including unit, integration, and edge cases
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

You are a test automation specialist focused on comprehensive test coverage.

## Your Responsibilities:
1. Generate unit tests for new/changed code
2. Create integration tests for component interactions
3. Identify and test edge cases
4. Ensure tests follow project conventions
5. Aim for >80% code coverage

## Test Types:
- **Unit Tests**: Individual function/method behavior
- **Integration Tests**: Component interactions
- **Edge Cases**: Boundary conditions, error states
- **Performance Tests**: When relevant

## Guidelines:
- Match existing test file patterns
- Use project's testing framework (detect from package.json)
- Include meaningful test descriptions
- Test both success and failure paths
- Mock external dependencies appropriately

## Output:
Generate test files with:
- Clear test descriptions
- Comprehensive coverage
- Proper setup/teardown
- Edge case handling
EOF

    # Reviewer sub-agent
    cat > .claude/agents/reviewer.md << 'EOF'
---
name: reviewer
description: Performs thorough code reviews focusing on quality, security, and best practices
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
permissionMode: auto
---

You are a senior code reviewer focused on quality and security.

## Review Checklist:
- [ ] Code follows style guidelines
- [ ] No security vulnerabilities
- [ ] Error handling is comprehensive
- [ ] Edge cases are handled
- [ ] Performance considerations
- [ ] Tests are included and comprehensive
- [ ] Documentation is updated
- [ ] No unnecessary complexity

## Security Checks:
- Scan for hardcoded credentials
- Check input validation
- Review authentication/authorization
- Identify potential injection vulnerabilities
- Verify secure communication

## Output Format:
Provide review as:
- **Status**: ✅ LGTM / ⚠️ Minor Issues / ❌ Needs Changes
- **Critical**: Blocking issues that must be fixed
- **Major**: Important issues to address
- **Minor**: Suggestions for improvement
- **Nits**: Style/preference comments
EOF

    # Implementer sub-agent
    cat > .claude/agents/implementer.md << 'EOF'
---
name: implementer
description: Implements features following specifications and architecture decisions
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

You are a senior developer focused on clean, maintainable implementation.

## Your Responsibilities:
1. Implement features according to specifications
2. Follow established patterns and conventions
3. Write self-documenting code
4. Include inline comments for complex logic
5. Update relevant documentation

## Implementation Guidelines:
- Follow SOLID principles
- Use established patterns from the codebase
- Keep functions small and focused
- Prefer composition over inheritance
- Write defensive code with proper error handling

## Process:
1. Read relevant spec/ADR documents
2. Review similar existing code for patterns
3. Identify affected tests
4. Plan implementation approach
5. Implement incrementally
6. Update tests and documentation
EOF

    echo -e "${GREEN}✓${NC} Sub-agents created"
}

# Create custom commands
create_commands() {
    echo ""
    echo "⚡ Creating custom commands..."
    
    # Review command
    cat > .claude/commands/review.md << 'EOF'
Perform a comprehensive code review of recent changes:

## Review Process:
1. Use git to identify changed files in the current branch
2. Spawn the `reviewer` sub-agent to analyze each file
3. Check for:
   - Code quality and adherence to conventions
   - Security vulnerabilities
   - Performance issues
   - Missing tests
   - Documentation gaps
4. Compile findings into a structured report

## Output:
Generate a review report with:
- Summary of changes
- Critical issues (must fix)
- Important issues (should fix)
- Suggestions (nice to have)
- Overall recommendation
EOF

    # Test generation command
    cat > .claude/commands/test-gen.md << 'EOF'
Generate comprehensive tests for the specified files:

## Steps:
1. Read the target file(s) and understand their functionality
2. Identify existing test files to match style/patterns
3. Generate tests covering:
   - Happy path scenarios
   - Edge cases and boundary conditions
   - Error handling
   - Mock external dependencies
4. Ensure >80% code coverage
5. Run tests to verify they pass

## Test Structure:
- Use descriptive test names
- Group related tests in describe blocks
- Include setup/teardown when needed
- Add comments for complex test scenarios
EOF

    # Feature command
    cat > .claude/commands/feature.md << 'EOF'
Create a new feature following our standard workflow:

## Steps:
1. Create feature branch: `feature/[TICKET]-[description]`
2. Use the architect sub-agent to:
   - Design the feature architecture
   - Create an ADR (Architectural Decision Record)
   - Identify affected components
3. Use the implementer sub-agent to:
   - Implement the feature following the ADR
   - Update relevant documentation
4. Use the tester sub-agent to:
   - Generate comprehensive tests
   - Ensure >80% coverage
5. Run tests to verify everything works
6. Create a PR with proper description

Ask the user for:
- Feature description
- Ticket number
- Any specific requirements or constraints
EOF

    echo -e "${GREEN}✓${NC} Custom commands created"
}

# Create CLAUDE.md template
create_claude_md() {
    echo ""
    echo "📝 Creating CLAUDE.md template..."
    
    cat > CLAUDE.md << 'EOF'
# Project: [Your Project Name]

## Overview
Brief description of what this project does and its architecture.

## Tech Stack
- **Language**: [TypeScript/JavaScript/Python/etc.]
- **Framework**: [Next.js/React/FastAPI/etc.]
- **Database**: [PostgreSQL/MongoDB/etc.]
- **Testing**: [Vitest/Jest/Pytest/etc.]
- **Package Manager**: [pnpm/npm/poetry/etc.]

## Code Conventions

### File Structure
- Use kebab-case for file names: `user-profile.tsx`
- Group related files in feature folders
- Colocate tests with source: `component.tsx` + `component.test.tsx`

### Coding Guidelines
- [Add your specific coding conventions]
- [Style guide references]
- [Naming conventions]

### Testing Guidelines
- Minimum 80% code coverage
- Test files follow `*.test.*` pattern
- Use descriptive test names
- Mock external API calls

### Git Workflow
- Branch naming: `feature/TICKET-123-description` or `fix/bug-description`
- Commit format: Conventional Commits (feat:, fix:, docs:, etc.)
- Always create PRs for changes
- Require 1 approval before merge

## Key Files and Directories
- `src/`: Source code
- `tests/`: Tests
- `docs/`: Documentation

## Common Tasks

### Running Tests
```bash
# Add your test commands
npm test
npm test:watch
npm test:coverage
```

## Important Patterns
[Document your project-specific patterns and best practices here]

## Performance Considerations
[Document performance requirements and optimization strategies]

## Security Guidelines
- Never commit secrets to git
- Validate all user inputs
- Use parameterized queries
- Implement CSRF protection
- Use HTTPS in production
EOF

    echo -e "${GREEN}✓${NC} CLAUDE.md template created"
}

# Create GitHub workflows
create_workflows() {
    echo ""
    echo "🔄 Creating GitHub workflows..."
    
    # PR review workflow
    cat > .github/workflows/claude-review.yml << 'EOF'
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]
  issue_comment:
    types: [created]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    if: |
      github.event_name == 'pull_request' || 
      (github.event_name == 'issue_comment' && 
       github.event.issue.pull_request && 
       contains(github.event.comment.body, '@claude'))
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Claude Code
        run: |
          curl -fsSL https://claude.ai/install.sh | bash
          echo "$HOME/.local/bin" >> $GITHUB_PATH

      - name: Review with Claude
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "Use the reviewer sub-agent to review this PR. Output in markdown format." \
            --output-format json > review-output.json

      - name: Post review comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = JSON.parse(fs.readFileSync('review-output.json', 'utf8'));
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: review.result
            });
EOF

    echo -e "${GREEN}✓${NC} GitHub workflows created"
}

# Create .gitignore if it doesn't exist
create_gitignore() {
    if [ ! -f .gitignore ]; then
        echo ""
        echo "📄 Creating .gitignore..."
        
        cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
*.lcov
.nyc_output

# Production
build/
dist/
.next/
out/

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Claude Code
.claude/cache/
.claude/logs/

# Misc
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

        echo -e "${GREEN}✓${NC} .gitignore created"
    fi
}

# Create a sample package.json if it doesn't exist
create_package_json() {
    if [ ! -f package.json ]; then
        echo ""
        echo "📦 Creating package.json template..."
        
        cat > package.json << 'EOF'
{
  "name": "claude-code-project",
  "version": "1.0.0",
  "description": "Project with Claude Code setup",
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vitest/coverage-v8": "^1.0.0"
  }
}
EOF

        echo -e "${GREEN}✓${NC} package.json template created"
    fi
}

# Setup git repository if not already initialized
setup_git() {
    if [ ! -d .git ]; then
        echo ""
        read -p "Initialize git repository? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git init
            git add .
            git commit -m "chore: initial Claude Code setup"
            echo -e "${GREEN}✓${NC} Git repository initialized"
        fi
    fi
}

# Create MCP configuration template
create_mcp_config() {
    echo ""
    echo "🔌 Creating MCP configuration template..."
    
    cat > .claude/mcp-config-template.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-github-token-here"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7"],
      "description": "Access up-to-date library documentation"
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your-brave-api-key-here"
      }
    }
  }
}
EOF

    echo -e "${GREEN}✓${NC} MCP config template created"
    echo -e "${YELLOW}Note:${NC} Copy .claude/mcp-config-template.json to ~/.claude.json and add your API keys"
}

# Create README for the setup
create_readme() {
    echo ""
    echo "📖 Creating README..."
    
    cat > README.md << 'EOF'
# Claude Code Expert Environment

This project is set up with a complete Claude Code development environment including sub-agents, custom commands, and CI/CD workflows.

## Quick Start

1. **Install Claude Code** (if not already installed):
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```

2. **Set your API key**:
   ```bash
   export ANTHROPIC_API_KEY='your-api-key-here'
   ```

3. **Start using Claude Code**:
   ```bash
   claude
   ```

## Available Sub-Agents

- **architect**: Reviews architecture and design decisions
- **tester**: Generates comprehensive tests
- **reviewer**: Performs code reviews
- **implementer**: Implements features following best practices

## Custom Commands

Use these commands in Claude Code:

- `/review` - Comprehensive code review of recent changes
- `/test-gen` - Generate tests for specified files
- `/feature` - Create a new feature following standard workflow

## GitHub Actions

The project includes automated workflows:

- **claude-review.yml**: Automated PR reviews (trigger with `@claude` comment)

## MCP Servers

Configure MCP servers by copying `.claude/mcp-config-template.json` to `~/.claude.json` and adding your API keys.

Recommended MCP servers:
- **github**: GitHub operations
- **context7**: Up-to-date library documentation
- **brave-search**: Web search for solutions

## Project Structure

```
.
├── .claude/
│   ├── agents/          # Sub-agent definitions
│   ├── commands/        # Custom slash commands
│   └── hooks/           # Lifecycle hooks
├── .github/
│   └── workflows/       # CI/CD workflows
├── src/                 # Source code
├── tests/               # Tests
├── docs/                # Documentation
└── CLAUDE.md            # Project context for Claude
```

## Documentation

- See `CLAUDE.md` for project-specific conventions and patterns
- See `claude-code-setup-guide.md` for complete setup documentation

## Next Steps

1. Customize `CLAUDE.md` with your project details
2. Add your API keys to MCP configuration
3. Set up `ANTHROPIC_API_KEY` as a GitHub secret for CI/CD
4. Try building a feature using sub-agents: `claude -p "use /feature to create a new user profile component"`

## Learning Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [MCP Server Registry](https://github.com/modelcontextprotocol)
- [Setup Guide](./claude-code-setup-guide.md)
EOF

    echo -e "${GREEN}✓${NC} README created"
}

# Main setup function
main() {
    echo ""
    echo "Starting setup process..."
    echo ""
    
    # Check if Claude Code is installed
    if ! check_claude_installed; then
        read -p "Would you like to install Claude Code now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_claude
        else
            echo -e "${YELLOW}Skipping Claude Code installation${NC}"
        fi
    fi
    
    # Create project structure
    create_project_structure
    
    # Create sub-agents
    create_subagents
    
    # Create custom commands
    create_commands
    
    # Create CLAUDE.md
    create_claude_md
    
    # Create workflows
    create_workflows
    
    # Create .gitignore
    create_gitignore
    
    # Create package.json
    create_package_json
    
    # Create MCP config
    create_mcp_config
    
    # Create README
    create_readme
    
    # Setup git
    setup_git
    
    echo ""
    echo "========================================"
    echo -e "${GREEN}✅ Setup complete!${NC}"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "1. Set your ANTHROPIC_API_KEY environment variable"
    echo "2. Customize CLAUDE.md with your project details"
    echo "3. Configure MCP servers (copy .claude/mcp-config-template.json to ~/.claude.json)"
    echo "4. Try: claude -p 'use the reviewer sub-agent to review this setup'"
    echo ""
    echo "For detailed documentation, see:"
    echo "- README.md"
    echo "- claude-code-setup-guide.md"
    echo ""
}

# Run main function
main
