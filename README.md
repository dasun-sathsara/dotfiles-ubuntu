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
-   **Idempotent Design:** Uses SHA256 checksums to track configuration changes and only updates files when necessary.
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

### Re-running the Script

The script is fully **idempotent** and can be safely run multiple times. It will:

-   **Skip unchanged configurations**: Only update files that have actually been modified
-   **Detect updates automatically**: When you pull updates to configuration files (`.zshrc`, `.tmux.conf`, `init.lua`), the script will automatically apply them
-   **Preserve existing installations**: Won't reinstall packages or tools that are already present
-   **Smart plugin management**: Only reinstalls tmux plugins when the configuration has changed

Simply run `./setup.sh` again anytime to:

-   Apply updated configuration files from the repository
-   Install any newly added packages or tools
-   Ensure your environment stays up to date

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

## Configuration File Management

The script uses an intelligent checksum-based system to manage configuration files:

### How It Works

-   **SHA256 checksums** are calculated for all configuration files (`.zshrc`, `.tmux.conf`, `init.lua`)
-   **Checksum storage**: File checksums are stored in `~/.dotfiles_checksums` for comparison between runs
-   **Change detection**: Files are only updated when:
    -   The source configuration has been modified (checksum changed)
    -   The destination file doesn't exist
    -   The destination file differs from the source

### Benefits

-   **Efficient updates**: Only processes files that have actually changed
-   **Preserved customizations**: Your existing configurations won't be overwritten unless the source has been updated
-   **Automatic backups**: Changed files are backed up before being replaced
-   **Clear feedback**: The script tells you exactly which files are being updated or skipped

### File Locations

```
~/.dotfiles_checksums     # Checksum tracking file
~/.dotfiles_backup_*      # Timestamped backup directories
/tmp/setup_*.log          # Installation logs
```

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
