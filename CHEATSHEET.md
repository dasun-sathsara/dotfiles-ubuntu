# Development Environment Cheatsheet

Quick reference for the most commonly used aliases and keybindings in this Ubuntu development environment.

## Zsh Aliases (.zshrc)

### Docker Shortcuts

```bash
dps         # docker ps -a (list all containers)
di          # docker images (list all images)
dv          # docker volume ls (list volumes)
dn          # docker network ls (list networks)
```

## Tmux Keybindings (.tmux.conf)

**Prefix Key:** `Ctrl+a` (instead of default Ctrl+b)

### Session Management

```bash
Ctrl+a + d              # Detach from session
tmux attach -t <name>   # Attach to session
tmux new -s <name>      # Create new named session
tmux ls                 # List sessions
```

### Window Management

```bash
Ctrl+a + c              # Create new window
Ctrl+a + Ctrl+h         # Previous window
Ctrl+a + Ctrl+l         # Next window
Ctrl+a + &              # Kill current window
```

### Pane Management

```bash
Ctrl+a + |              # Split pane horizontally
Ctrl+a + -              # Split pane vertically
Ctrl+a + h/j/k/l        # Navigate between panes (vim-style)
Ctrl+a + H/J/K/L        # Resize panes (hold and repeat)
Ctrl+a + x              # Kill current pane
```

### Copy Mode

```bash
Ctrl+a + Enter          # Enter copy mode
v                       # Begin selection (in copy mode)
y                       # Copy selection to clipboard
Ctrl+v                  # Rectangle selection toggle
```

### Configuration

```bash
Ctrl+a + r              # Reload tmux configuration
Ctrl+a + I              # Install plugins (TPM)
```

## Neovim Keybindings (init.lua)

**Leader Key:** `Space`

### Mode Switching

```bash
jj                      # Exit insert mode (alternative to Esc)
```

### File Operations

```bash
<leader>w               # Save file (:w)
<leader>q               # Quit (:q)
```

### Window Navigation

```bash
Ctrl+h                  # Move to left window
Ctrl+j                  # Move to bottom window
Ctrl+k                  # Move to top window
Ctrl+l                  # Move to right window
```

### Visual Mode (Selection)

```bash
J                       # Move selected lines down
K                       # Move selected lines up
```

### Navigation & Search

```bash
Ctrl+d                  # Page down and center cursor
Ctrl+u                  # Page up and center cursor
Esc                     # Clear search highlights
```

### Basic Vim Commands (Essential)

```bash
i                       # Insert mode at cursor
a                       # Insert mode after cursor
o                       # New line below and insert
O                       # New line above and insert
x                       # Delete character under cursor
dd                      # Delete entire line
yy                      # Copy (yank) entire line
p                       # Paste after cursor
P                       # Paste before cursor
u                       # Undo
Ctrl+r                  # Redo
/                       # Search forward
?                       # Search backward
n                       # Next search result
N                       # Previous search result
```

## Tips

-   **Tmux**: Always work inside tmux sessions for persistence
-   **Neovim**: Use `jj` instead of Esc for faster mode switching
-   **Docker**: Use `dps` to quickly see all containers (running and stopped)
