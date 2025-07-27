# Ubuntu Development Environment Setup

A comprehensive, opinionated script to automate the setup of a modern development environment on Ubuntu 24.04+ and 25.04+ systems. This script installs and configures essential tools, hardens security, and sets up a productive shell, terminal multiplexer, and editor environment.

## Features

-   **Shell:** Zsh with Oh My Zsh, Agnoster theme, auto-suggestions, and syntax highlighting.
-   **Multiplexer:** Tmux with enhanced navigation, Catppuccin theme, session resurrection, and TPM for plugin management.
-   **Editor:** Neovim with a modern Lua-based configuration using `lazy.nvim`.
-   **Languages & Runtimes:** Go (latest stable), Python (with `uv`), and Node.js (with `pnpm`).
-   **Tooling:** Docker, Docker Compose, `htop`, `fastfetch`, and modern file utilities (`eza`/`exa`, `bat`).
-   **Security:** Disables SSH password authentication in favor of SSH keys.
-   **Compatibility:** Automatically detects Ubuntu version and adapts installation methods for optimal compatibility.
-   **Automation:** The entire process is handled by a single, robust bash script with comprehensive error handling, progress tracking, and automatic backups.

## Supported Versions

-   **Ubuntu 24.04 LTS (Noble Numbat)** - Fully supported
-   **Ubuntu 24.10 (Oracular Oriole)** - Fully supported
-   **Ubuntu 25.04 (Plucky Puffin)** - Fully supported
-   **Ubuntu 25.10 (Questing Quokka)** - Fully supported

The script automatically detects your Ubuntu version and adapts package installation methods accordingly, with intelligent fallbacks for newer versions.

## Prerequisites

-   A fresh Ubuntu 24.04+ or 25.04+ installation (minimal or desktop).
-   An SSH key configured for the user on the server (for SSH hardening).
-   `git` and `curl` installed (`sudo apt-get install git curl`).
-   Internet connection for downloading packages and tools.

## Usage

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/ubuntu-dev-setup.git
    cd ubuntu-dev-setup
    ```

2.  **Make the script executable:**

    ```bash
    chmod +x setup.sh
    ```

3.  **Run the setup script:**

    ```bash
    ./setup.sh
    ```

4.  **Reboot the system:**

    ```bash
    sudo reboot
    ```

5.  **After reboot, install tmux plugins:**
    ```bash
    tmux
    # Press Ctrl+a + I to install plugins
    ```

## What Gets Installed

### Development Tools

-   **Go**: Latest stable version (with fallback installation methods)
-   **Python**: Python 3 with `uv` package manager
-   **Node.js**: With `pnpm` package manager
-   **Build tools**: GCC, make, and essential build dependencies

### CLI Utilities

-   **Modern replacements**: `eza`/`exa` (better ls), `bat` (better cat)
-   **System tools**: `htop`, `fastfetch`, `xclip`
-   **Text editor**: Neovim with Lua configuration

### Container Platform

-   **Docker**: Latest Docker CE with Docker Compose
-   **Fallback support**: For newer Ubuntu versions without official Docker repos

### Shell Environment

-   **Zsh**: Default shell with Oh My Zsh framework
-   **Theme**: Agnoster with powerline fonts
-   **Plugins**: Auto-suggestions and syntax highlighting
-   **Smart aliases**: Automatically adapt based on installed tools

### Terminal Multiplexer

-   **Tmux**: Enhanced configuration with custom key bindings
-   **Plugins**: TPM, Catppuccin theme, session management
-   **Features**: Session resurrection and continuum

## Version Compatibility Features

The script includes several compatibility enhancements:

-   **Automatic version detection**: Identifies Ubuntu version and codename
-   **Package fallbacks**: Tries `eza` then `exa`, `bat` then `batcat`
-   **Go installation**: Official binary download with apt/PPA fallbacks
-   **Docker repository**: Native repo with fallback to Ubuntu 24.04 repo for newer versions
-   **Smart aliases**: Shell aliases adapt based on actually installed tools

## Troubleshooting

### For Ubuntu 25.04+

If you encounter package availability issues:

-   The script automatically falls back to Ubuntu 24.04 repositories for Docker
-   Go is installed via official binaries when possible
-   File utilities use the newest available version (`eza` preferred over `exa`)

### General Issues

-   Check the log file location displayed during setup for detailed error information
-   Configuration backups are saved with timestamps for easy restoration
-   Most issues can be resolved by re-running the script (it's idempotent)

## File Structure

```
dotfiles-ubuntu/
├── setup.sh           # Main installation script
├── .zshrc             # Zsh configuration with smart aliases
├── .tmux.conf         # Tmux configuration
├── init.lua           # Neovim configuration
├── README.md          # This file
└── .gitignore         # Git ignore patterns
```
