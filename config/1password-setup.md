# 1Password CLI Setup Guide

This guide helps you set up 1Password CLI integration for secure credential management in your shell environment.

## Prerequisites

1. **1Password Desktop App**: Install from https://1password.com/downloads
2. **1Password CLI**: Install with Homebrew:
   ```bash
   brew install 1password-cli
   ```

## Setup Steps

### 1. Enable 1Password CLI in Desktop App

1. Open 1Password desktop app
2. Go to Settings → Developer
3. Enable "Connect with 1Password CLI"

### 2. Sign In to 1Password CLI

```bash
# Sign in (you'll be prompted for your account details)
op signin

# Or sign in to a specific account
op signin my.1password.com user@example.com
```

### 3. Create a "dotfiles" Vault

1. In 1Password desktop app, create a new vault called "dotfiles"
2. This vault will store all your development credentials

### 4. Add Your Credentials

Add items to your "dotfiles" vault with these recommended names and fields:

#### GitHub Credentials
- **Item Name**: "GitHub"
- **Fields**:
  - `api-token` (your GitHub Personal Access Token)

#### Anthropic API Key
- **Item Name**: "Anthropic"
- **Fields**:
  - `api-key` (your Anthropic API key for Claude)

#### SSH Key
- **Item Name**: "SSH Key"
- **Fields**:
  - `private key` (your SSH private key content)

### 5. Test the Integration

```bash
# Check if you're signed in
op whoami

# Test retrieving a credential
op read "op://dotfiles/GitHub/api-token"

# Set up development environment
op-setup-env

# Check 1Password status
op-status
```

## Available Shell Functions

Once set up, you can use these shell functions:

- `op-status` - Check 1Password connection status
- `op-setup-env` - Load development environment variables from 1Password
- `op-get-env <item> <field>` - Retrieve specific credentials
- `op-inject-ssh` - Load SSH key for git operations

## Security Best Practices

1. **Never commit credentials to git** - Always use 1Password for secrets
2. **Use vault-specific organization** - Keep development credentials in the "dotfiles" vault
3. **Regular rotation** - Update API keys and tokens regularly
4. **Minimal permissions** - Use tokens with minimal required permissions
5. **Session management** - 1Password CLI sessions expire automatically for security

## Troubleshooting

### "not currently signed in" Error

```bash
# Re-authenticate
op signin
```

### Can't Find Item or Field

```bash
# List all vaults
op vault list

# List items in dotfiles vault
op item list --vault dotfiles

# Get item details
op item get "GitHub" --vault dotfiles
```

### Desktop App Integration Issues

1. Restart 1Password desktop app
2. Re-enable CLI integration in Settings → Developer
3. Try signing out and back in: `op signout && op signin`

## Adding New Credentials

To add support for new development tools:

1. **Add the credential to 1Password**:
   - Create item in "dotfiles" vault
   - Use clear, consistent naming

2. **Update shell/functions.zsh**:
   - Add export line to `op-setup-env()` function
   - Follow the existing pattern

3. **Test the integration**:
   ```bash
   # Source the updated configuration
   source ~/.zshrc

   # Test loading the new credential
   op-setup-env
   ```

## Example Workflow

```bash
# Start of day: set up development environment
op signin                    # Sign in to 1Password
op-setup-env                # Load all development credentials
op-inject-ssh               # Load SSH key for git operations

# Your environment variables are now set:
# - $GITHUB_TOKEN
# - $ANTHROPIC_API_KEY
# - SSH key loaded for git

# Work on your projects with authenticated access
git clone git@github.com:user/repo.git
claude --version  # Uses $ANTHROPIC_API_KEY
gh api user       # Uses $GITHUB_TOKEN
```

This setup ensures your credentials are secure, never stored in plaintext files, and easily accessible for development work.
