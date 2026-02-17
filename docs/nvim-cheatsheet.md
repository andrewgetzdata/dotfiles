# Neovim Cheatsheet

Leader: `Space`

## Movement

| Command | Description |
|---------|-------------|
| `h j k l` | Left, down, up, right |
| `w` | Next word |
| `b` | Previous word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | Top of file |
| `G` | Bottom of file |
| `Ctrl-d` | Half page down |
| `Ctrl-u` | Half page up |
| `%` | Jump to matching bracket |

## Editing

| Command | Description |
|---------|-------------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | New line below |
| `O` | New line above |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste after |
| `P` | Paste before |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `.` | Repeat last command |
| `ciw` | Change inner word |
| `ci"` | Change inside quotes |
| `di(` | Delete inside parentheses |

## Search

| Command | Description |
|---------|-------------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `*` | Search word under cursor |

## Visual Mode

| Command | Description |
|---------|-------------|
| `v` | Character selection |
| `V` | Line selection |
| `Ctrl-v` | Block selection |
| `>` | Indent selection |
| `<` | Unindent selection |

## Splits

| Command | Description |
|---------|-------------|
| `:vs` | Vertical split |
| `:sp` | Horizontal split |
| `Ctrl-h` | Move left (works across tmux panes) |
| `Ctrl-j` | Move down |
| `Ctrl-k` | Move up |
| `Ctrl-l` | Move right |

## Telescope (file finder)

| Command | Description |
|---------|-------------|
| `Space ff` | Find files |
| `Space fg` | Live grep (search contents) |
| `Space fb` | Switch buffers |
| `Space fh` | Search help tags |

## Files & Buffers

| Command | Description |
|---------|-------------|
| `:e filename` | Open file |
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Close buffer |

## Other

| Command | Description |
|---------|-------------|
| `:set number` | Toggle line numbers |
| `:noh` | Clear search highlight |
| `ZZ` | Save and quit |
| `ZQ` | Quit without saving |
