# Ubuntu Development Environment Setup

A comprehensive, opinionated script to automate the setup of a modern development environment on a minimal Ubuntu 25 system. This script installs and configures essential tools, hardens security, and sets up a productive shell, terminal multiplexer, and editor environment.

## Features

-   **Shell:** Zsh with Oh My Zsh, Agnoster theme, auto-suggestions, and syntax highlighting.
-   **Multiplexer:** Tmux with enhanced navigation, Catppuccin theme, session resurrection, and TPM for plugin management.
-   **Editor:** Neovim with a modern Lua-based configuration using `lazy.nvim`.
-   **Languages & Runtimes:** Go, Python (with `uv`), and Node.js (with `pnpm`).
-   **Tooling:** Docker, Docker Compose, `htop`, `fastfetch`, and `exa` (as `ls` alias).
-   **Security:** Disables SSH password authentication in favor of SSH keys.
-   **Automation:** The entire process is handled by a single, robust bash script with comprehensive error handling, progress tracking, and automatic backups.

## Prerequisites

-   A fresh Ubuntu 25 Minimal installation.
-   An SSH key configured for the user on the server.
-   `git` and `curl` installed (`sudo apt-get install git curl`).

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
