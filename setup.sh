#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Exit immediately if a command in a pipeline fails.
set -o pipefail

# --- Global Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/setup_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# --- Pretty Output Functions ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "\033[33m[WARNING]\033[0m $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" | tee -a "$LOG_FILE"
    cleanup_on_error
    exit 1
}

progress() {
    local current=$1
    local total=$2
    local desc=$3
    echo -e "\033[36m[PROGRESS]\033[0m [$current/$total] $desc" | tee -a "$LOG_FILE"
}

# --- Utility Functions ---
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        info "Backed up $file to $BACKUP_DIR/$(basename "$file")"
    fi
}

cleanup_on_error() {
    warning "Setup failed. Cleaning up temporary files..."
    if [[ -d "/tmp/oh-my-zsh-install" ]]; then
        rm -rf "/tmp/oh-my-zsh-install"
    fi
    info "Cleanup completed. Check log file: $LOG_FILE"
}

check_internet() {
    info "Checking internet connectivity..."
    if ! ping -c 1 google.com &> /dev/null; then
        error "No internet connection available. Setup requires internet access."
    fi
    success "Internet connectivity confirmed."
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
}

install_package() {
    local package=$1
    if dpkg -l | grep -q "^ii  $package "; then
        info "$package is already installed."
    else
        info "Installing $package..."
        sudo apt-get install -y "$package" || error "Failed to install $package"
        success "$package installed successfully."
    fi
}

# --- Main Setup Functions ---
initial_setup() {
    progress 1 10 "Initial system setup"
    check_root
    check_internet
    
    info "Starting the development environment setup..."
    info "Log file: $LOG_FILE"
    
    info "Updating system packages..."
    sudo apt-get update && sudo apt-get upgrade -y || error "Failed to update system packages"
    success "System packages updated and upgraded."
}

install_packages() {
    progress 2 10 "Installing core packages"
    info "Installing necessary packages..."
    
    local packages=(
        "neovim" "tmux" "zsh" "htop" "fastfetch" "exa"
        "npm" "python3" "python3-venv" "python3-pip"
        "build-essential" "curl" "file" "git" "xclip"
        "ca-certificates" "software-properties-common"
    )
    
    for package in "${packages[@]}"; do
        install_package "$package"
    done
    
    success "Core packages installed."
}

install_pnpm() {
    progress 3 10 "Installing pnpm"
    if command_exists pnpm; then
        info "pnpm is already installed."
    else
        info "Installing pnpm..."
        npm install -g pnpm || error "Failed to install pnpm"
        success "pnpm installed."
    fi
}

install_uv() {
    progress 4 10 "Installing uv (Python package manager)"
    if command_exists uv; then
        info "uv is already installed."
    else
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh || error "Failed to install uv"
        source "$HOME/.cargo/env" 2>/dev/null || true
        success "uv installed."
    fi
}

install_go() {
    progress 5 10 "Installing Go"
    if command_exists go; then
        info "Go is already installed."
    else
        info "Installing Go..."
        sudo add-apt-repository -y ppa:longsleep/golang-backports || error "Failed to add Go repository"
        sudo apt-get update || error "Failed to update package list"
        sudo apt-get install -y golang-go || error "Failed to install Go"
        success "Go installed."
    fi
}

setup_zsh() {
    progress 6 10 "Setting up Zsh with Oh My Zsh"
    info "Setting up Zsh..."
    
    # Install Oh My Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error "Failed to install Oh My Zsh"
    else
        info "Oh My Zsh is already installed."
    fi
    
    # Install plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" || error "Failed to install zsh-autosuggestions"
    fi
    
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" || error "Failed to install zsh-syntax-highlighting"
    fi
    
    # Backup and copy zshrc
    backup_file "$HOME/.zshrc"
    cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" || error "Failed to copy .zshrc"
    
    # Change default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)" || warning "Failed to change default shell. You may need to log out and back in."
    fi
    
    success "Zsh is configured with Oh My Zsh and agnoster theme."
}

setup_tmux() {
    progress 7 10 "Setting up Tmux"
    info "Setting up Tmux..."
    
    # Install TPM if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || error "Failed to install TPM"
    else
        info "TPM is already installed."
    fi
    
    # Backup and copy tmux.conf
    backup_file "$HOME/.tmux.conf"
    cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf" || error "Failed to copy .tmux.conf"
    
    # Install plugins
    info "Installing Tmux plugins..."
    if command_exists tmux; then
        # Kill any existing tmux sessions to avoid conflicts
        tmux kill-server 2>/dev/null || true
        tmux start-server || true
        tmux new-session -d -s setup_session || true
        "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" || warning "Failed to install some tmux plugins automatically"
        tmux kill-session -t setup_session 2>/dev/null || true
    fi
    
    success "Tmux configured with enhanced features and plugins."
}

setup_neovim() {
    progress 8 10 "Setting up Neovim"
    info "Setting up Neovim..."
    
    mkdir -p "$HOME/.config/nvim"
    backup_file "$HOME/.config/nvim/init.lua"
    cp "$SCRIPT_DIR/init.lua" "$HOME/.config/nvim/init.lua" || error "Failed to copy init.lua"
    
    success "Neovim configuration created."
}

setup_docker() {
    progress 9 10 "Setting up Docker"
    if command_exists docker; then
        info "Docker is already installed."
        return
    fi
    
    info "Setting up Docker..."
    
    # Install prerequisites
    sudo apt-get install -y ca-certificates curl || error "Failed to install Docker prerequisites"
    
    # Add Docker GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || error "Failed to download Docker GPG key"
        sudo chmod a+r /etc/apt/keyrings/docker.asc
    fi
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error "Failed to add Docker repository"
    
    # Install Docker
    sudo apt-get update || error "Failed to update package list"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker"
    
    # Add user to docker group
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER" || error "Failed to add user to docker group"
    
    success "Docker and Docker Compose installed. Docker can be run as a non-root user after reboot."
}

harden_ssh() {
    progress 10 10 "Hardening SSH configuration"
    info "Hardening SSH configuration..."
    
    # Backup SSH config
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup."$(date +%Y%m%d_%H%M%S)"
    
    # Disable password authentication
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # Test SSH configuration
    if sudo sshd -t; then
        sudo systemctl restart sshd || error "Failed to restart SSH service"
        success "Password authentication for SSH has been disabled."
    else
        error "SSH configuration test failed. Reverting changes."
    fi
}

final_cleanup() {
    info "Performing final cleanup..."
    
    # Clean up temporary files
    sudo apt-get autoremove -y >/dev/null 2>&1 || true
    sudo apt-get autoclean >/dev/null 2>&1 || true
    
    success "Setup completed successfully!"
    echo ""
    info "=== SETUP SUMMARY ==="
    info "✓ System packages updated"
    info "✓ Development tools installed (Go, Python/uv, Node.js/pnpm)"
    info "✓ Zsh configured with Oh My Zsh and agnoster theme"
    info "✓ Tmux configured with enhanced features and plugins"
    info "✓ Neovim configuration installed"
    info "✓ Docker and Docker Compose installed"
    info "✓ SSH hardened (password auth disabled)"
    info "✓ Configuration backups saved to: $BACKUP_DIR"
    info "✓ Installation log saved to: $LOG_FILE"
    echo ""
    warning "IMPORTANT: Please reboot your system for all changes to take effect."
    warning "After reboot, run 'tmux' and press Ctrl+a + I to install tmux plugins."
}

# --- Main Execution ---
main() {
    echo "======================================"
    echo "  Ubuntu Development Environment Setup"
    echo "======================================"
    echo ""
    
    initial_setup
    install_packages
    install_pnpm
    install_uv
    install_go
    setup_zsh
    setup_tmux
    setup_neovim
    setup_docker
    harden_ssh
    final_cleanup
}

# Run main function
main "$@"
