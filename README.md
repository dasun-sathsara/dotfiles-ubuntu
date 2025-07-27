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
