# Ubuntu Development Environment Setup

A comprehensive script to automate the setup of a modern development environment on Ubuntu 24.04+ systems.

## Features

-   **Shell:** Zsh with Oh My Zsh, Agnoster theme, auto-suggestions, and syntax highlighting
-   **Multiplexer:** Tmux with enhanced navigation, Catppuccin theme, and session management
-   **Editor:** Neovim with a modern Lua-based configuration
-   **Languages & Runtimes:** Go, Rust (with Cargo), Python (with `uv`), and Node.js (with `pnpm`)
-   **Tooling:** Docker, Docker Compose, `htop`, `fastfetch`, and modern file utilities (`eza`/`exa`, `bat`)
-   **Security:** Disables SSH password authentication in favor of SSH keys
-   **Idempotent Design:** Safe to run multiple times with automatic change detection

## Supported Versions

-   **Ubuntu 24.04 LTS** - Fully supported
-   **Ubuntu 24.10** - Fully supported
-   **Ubuntu 25.04** - Fully supported
-   **Ubuntu 25.10** - Fully supported

## Quick Start

1. **Clone and run:**

    ```bash
    git clone https://github.com/your-username/dotfiles-ubuntu.git
    cd dotfiles-ubuntu
    chmod +x setup.sh
    ./setup.sh
    ```

2. **Reboot:**

    ```bash
    sudo reboot
    ```

3. **Install tmux plugins (after reboot):**
    ```bash
    tmux
    # Press Ctrl+a + I to install plugins
    ```

## What Gets Installed

### Development Tools

-   **Go**: Latest stable version
-   **Rust**: Latest stable version via rustup with Cargo package manager
-   **Python**: Python 3 with `uv` package manager
-   **Node.js**: With `pnpm` package manager
-   **Build tools**: GCC, make, and essential build dependencies

### CLI Utilities

-   **Modern replacements**: `eza`/`exa` (better ls), `bat` (better cat)
-   **System tools**: `htop`, `fastfetch`, `xclip`
-   **Text editor**: Neovim with Lua configuration

### Container Platform

-   **Docker**: Latest Docker CE with Docker Compose

### Shell Environment

-   **Zsh**: Default shell with Oh My Zsh framework
-   **Theme**: Agnoster with powerline fonts
-   **Plugins**: Auto-suggestions and syntax highlighting
-   **Smart aliases**: Automatically adapt based on installed tools

### Terminal Multiplexer

-   **Tmux**: Enhanced configuration with custom key bindings
-   **Plugins**: TPM, Catppuccin theme, session management
-   **Features**: Session resurrection and continuum

## Re-running the Script

The script is **idempotent** and can be safely run multiple times. It will:

-   Skip unchanged configurations using SHA256 checksums
-   Only update files that have actually been modified
-   Preserve existing installations
-   Apply updated configuration files automatically

Simply run `./setup.sh` again to apply any updates.

## File Structure

```
dotfiles-ubuntu/
├── setup.sh           # Main installation script
├── .zshrc             # Zsh configuration with smart aliases
├── .tmux.conf         # Tmux configuration
├── init.lua           # Neovim configuration
├── README.md          # This file
├── CHEATSHEET.md      # Quick reference for aliases and keybindings
└── .gitignore         # Git ignore patterns
```

## Quick Reference

After installation, check `CHEATSHEET.md` for the most commonly used:

-   Zsh aliases (file operations, git shortcuts, docker commands)
-   Tmux keybindings (session/window/pane management)
-   Neovim keybindings (editing and navigation)
-   Development tool commands (cargo, go, uv, pnpm)

## Troubleshooting

-   **For Ubuntu 25.04+**: The script automatically falls back to Ubuntu 24.04 repositories when needed
-   **Package issues**: Most issues can be resolved by re-running the script
-   **Logs**: Check the log file location displayed during setup for detailed error information
-   **Backups**: Configuration backups are saved with timestamps for easy restoration
