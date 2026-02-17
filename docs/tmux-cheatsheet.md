# tmux Cheatsheet

Prefix: `Ctrl-a`

## Sessions

| Command | Description |
|---------|-------------|
| `tmux new -s name` | New session |
| `tmux attach -t name` | Attach to session |
| `tmux ls` | List sessions |
| `Ctrl-a d` | Detach from session |
| `Ctrl-a $` | Rename session |

## Windows

| Command | Description |
|---------|-------------|
| `Ctrl-a c` | New window |
| `Ctrl-a n` | Next window |
| `Ctrl-a p` | Previous window |
| `Ctrl-a 1-9` | Jump to window by number |
| `Ctrl-a ,` | Rename window |
| `Ctrl-a &` | Close window |

## Panes

| Command | Description |
|---------|-------------|
| `Ctrl-a \|` | Vertical split |
| `Ctrl-a -` | Horizontal split |
| `Ctrl-a x` | Close pane |
| `Ctrl-a z` | Toggle pane fullscreen (zoom) |
| `Ctrl-a {` | Move pane left |
| `Ctrl-a }` | Move pane right |
| `Ctrl-a Space` | Cycle pane layouts |

## Navigation (vim-tmux-navigator)

| Command | Description |
|---------|-------------|
| `Ctrl-h` | Move left (works across nvim splits) |
| `Ctrl-j` | Move down |
| `Ctrl-k` | Move up |
| `Ctrl-l` | Move right |

## Copy Mode

| Command | Description |
|---------|-------------|
| `Ctrl-a [` | Enter copy mode (vi keys to navigate) |
| `v` | Start selection (in copy mode) |
| `y` | Copy selection to clipboard (in copy mode) |
| `q` | Exit copy mode |

## Other

| Command | Description |
|---------|-------------|
| `Ctrl-a r` | Reload config |
| `Ctrl-a ?` | List all keybindings |
| `Ctrl-a :` | Command prompt |
