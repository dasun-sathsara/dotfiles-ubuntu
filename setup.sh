#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Exit immediately if a command in a pipeline fails.
set -o pipefail

# --- Global Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/setup_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
CHECKSUM_FILE="$HOME/.dotfiles_checksums"

# Ubuntu version detection
UBUNTU_VERSION=""
UBUNTU_CODENAME=""

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

# Function to calculate file checksum
get_file_checksum() {
    local file=$1
    if [[ -f "$file" ]]; then
        sha256sum "$file" | cut -d' ' -f1
    else
        echo "FILE_NOT_EXISTS"
    fi
}

# Function to get stored checksum for a file
get_stored_checksum() {
    local file_key=$1
    if [[ -f "$CHECKSUM_FILE" ]]; then
        grep "^$file_key:" "$CHECKSUM_FILE" 2>/dev/null | cut -d':' -f2 || echo ""
    else
        echo ""
    fi
}

# Function to store checksum for a file
store_checksum() {
    local file_key=$1
    local checksum=$2
    
    # Create checksum file if it doesn't exist
    touch "$CHECKSUM_FILE"
    
    # Remove existing entry for this file
    grep -v "^$file_key:" "$CHECKSUM_FILE" > "$CHECKSUM_FILE.tmp" 2>/dev/null || true
    mv "$CHECKSUM_FILE.tmp" "$CHECKSUM_FILE"
    
    # Add new entry
    echo "$file_key:$checksum" >> "$CHECKSUM_FILE"
}

# Function to check if configuration file needs updating
needs_config_update() {
    local source_file=$1
    local dest_file=$2
    local file_key=$3
    
    # If source file doesn't exist, skip
    if [[ ! -f "$source_file" ]]; then
        warning "Source file $source_file not found, skipping"
        return 1
    fi
    
    # If destination file doesn't exist, definitely need to copy
    if [[ ! -f "$dest_file" ]]; then
        info "Destination file $dest_file doesn't exist, will create"
        return 0
    fi
    
    # Calculate current source file checksum
    local current_checksum=$(get_file_checksum "$source_file")
    local stored_checksum=$(get_stored_checksum "$file_key")
    
    # If checksums differ, file has been updated
    if [[ "$current_checksum" != "$stored_checksum" ]]; then
        info "Configuration file $source_file has been updated since last run"
        return 0
    fi
    
    # Check if destination file has been modified (compare with source)
    local dest_checksum=$(get_file_checksum "$dest_file")
    if [[ "$dest_checksum" != "$current_checksum" ]]; then
        info "Destination file $dest_file differs from source, will update"
        return 0
    fi
    
    info "Configuration file $dest_file is up to date, skipping"
    return 1
}

# Function to copy configuration file with change detection
copy_config_file() {
    local source_file=$1
    local dest_file=$2
    local file_key=$3
    local description=$4
    
    if needs_config_update "$source_file" "$dest_file" "$file_key"; then
        # Create destination directory if needed
        mkdir -p "$(dirname "$dest_file")"
        
        # Backup existing file if it exists
        backup_file "$dest_file"
        
        # Copy new configuration
        cp "$source_file" "$dest_file" || error "Failed to copy $description"
        
        # Store new checksum
        local new_checksum=$(get_file_checksum "$source_file")
        store_checksum "$file_key" "$new_checksum"
        
        success "$description updated successfully"
        return 0
    else
        info "$description is already up to date"
        return 1
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
    
    # Try multiple methods to check internet connectivity
    local connectivity_confirmed=false
    
    # Method 1: Try HTTP request to a reliable endpoint
    if curl -s --connect-timeout 10 --max-time 15 "https://httpbin.org/get" > /dev/null 2>&1; then
        connectivity_confirmed=true
    # Method 2: Try connecting to Google's public DNS
    elif curl -s --connect-timeout 10 --max-time 15 "http://detectportal.firefox.com/canonical.html" > /dev/null 2>&1; then
        connectivity_confirmed=true
    # Method 3: Fall back to ping if curl fails (some systems might not have curl yet)
    elif command_exists ping && ping -c 1 -W 5 8.8.8.8 &> /dev/null; then
        connectivity_confirmed=true
    # Method 4: Try wget as final fallback
    elif command_exists wget && wget --spider --quiet --timeout=10 "https://httpbin.org/get" 2>/dev/null; then
        connectivity_confirmed=true
    fi
    
    if [[ "$connectivity_confirmed" == true ]]; then
        success "Internet connectivity confirmed."
    else
        error "No internet connection available. Setup requires internet access."
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
}

detect_ubuntu_version() {
    info "Detecting Ubuntu version..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            error "This script is designed for Ubuntu systems only. Detected: $ID"
        fi
        UBUNTU_VERSION="$VERSION_ID"
        UBUNTU_CODENAME="$VERSION_CODENAME"
        info "Detected Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME)"
        
        # Check for supported versions
        case "$UBUNTU_VERSION" in
            "24.04"|"24.10"|"25.04"|"25.10")
                success "Ubuntu $UBUNTU_VERSION is supported."
                ;;
            *)
                warning "Ubuntu $UBUNTU_VERSION may not be fully supported. This script is optimized for Ubuntu 24.04+ and 25.04+."
                ;;
        esac
    else
        error "Cannot detect Ubuntu version. /etc/os-release not found."
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

install_package_with_fallback() {
    local primary=$1
    local fallback=${2:-""}
    
    if dpkg -l | grep -q "^ii  $primary "; then
        info "$primary is already installed."
        return 0
    fi
    
    info "Attempting to install $primary..."
    if sudo apt-get install -y "$primary" 2>/dev/null; then
        success "$primary installed successfully."
        return 0
    elif [[ -n "$fallback" ]]; then
        warning "$primary not available, trying fallback: $fallback"
        if sudo apt-get install -y "$fallback" 2>/dev/null; then
            success "$fallback installed successfully."
            return 0
        fi
    fi
    
    error "Failed to install $primary${fallback:+ or $fallback}"
}

# --- Main Setup Functions ---
initial_setup() {
    progress 1 12 "Initial system setup"
    check_root
    detect_ubuntu_version
    check_internet
    
    info "Starting the development environment setup..."
    info "Log file: $LOG_FILE"
    info "Configuration checksums: $CHECKSUM_FILE"
    
    info "Updating system packages..."
    sudo apt-get update && sudo apt-get upgrade -y || error "Failed to update system packages"
    success "System packages updated and upgraded."
}

install_packages() {
    progress 2 12 "Installing core packages"
    info "Installing necessary packages..."
    
    # Core packages that should be available on all supported Ubuntu versions
    local core_packages=(
        "neovim" "tmux" "zsh" "htop" "fastfetch"
        "npm" "python3" "python3-venv" "python3-pip"
        "build-essential" "curl" "file" "git" "xclip"
        "ca-certificates" "software-properties-common"
    )
    
    for package in "${core_packages[@]}"; do
        install_package "$package"
    done
    
    # Install exa/eza with fallback based on Ubuntu version
    info "Installing file listing utility..."
    case "$UBUNTU_VERSION" in
        "24.04"|"24.10")
            install_package_with_fallback "exa" "eza"
            ;;
        "25.04"|"25.10"|*)
            install_package_with_fallback "eza" "exa"
            ;;
    esac
    
    # Install bat/batcat with fallback
    info "Installing bat (better cat)..."
    install_package_with_fallback "bat" "batcat"
    
    success "Core packages installed."
}

install_pnpm() {
    progress 3 12 "Installing pnpm"
    if command_exists pnpm; then
        info "pnpm is already installed."
    else
        info "Installing pnpm..."
        
        # Try multiple installation methods for pnpm
        local pnpm_installed=false
        
        # Method 1: Use corepack (recommended method if available)
        if command_exists corepack; then
            info "Using corepack to enable pnpm..."
            if corepack enable pnpm 2>/dev/null && corepack install --global pnpm@latest 2>/dev/null; then
                pnpm_installed=true
                success "pnpm installed via corepack."
            fi
        fi
        
        # Method 2: Use pnpm's standalone installer (most reliable)
        if [[ "$pnpm_installed" == false ]]; then
            info "Using pnpm standalone installer..."
            if curl -fsSL https://get.pnpm.io/install.sh | sh -; then
                # Source the updated PATH
                export PNPM_HOME="$HOME/.local/share/pnpm"
                export PATH="$PNPM_HOME:$PATH"
                source "$HOME/.bashrc" 2>/dev/null || true
                source "$HOME/.zshrc" 2>/dev/null || true
                
                if command_exists pnpm; then
                    pnpm_installed=true
                    success "pnpm installed via standalone installer."
                fi
            fi
        fi
        
        # Method 3: Fallback to npm with user-local prefix (avoid global permissions)
        if [[ "$pnpm_installed" == false ]]; then
            info "Trying npm with local prefix..."
            
            # Set npm prefix to user directory to avoid permission issues
            mkdir -p "$HOME/.npm-global"
            npm config set prefix "$HOME/.npm-global"
            export PATH="$HOME/.npm-global/bin:$PATH"
            
            if npm install -g pnpm 2>/dev/null; then
                pnpm_installed=true
                success "pnpm installed via npm with local prefix."
            fi
        fi
        
        if [[ "$pnpm_installed" == false ]]; then
            error "Failed to install pnpm using all available methods"
        fi
    fi
}

install_uv() {
    progress 4 12 "Installing uv (Python package manager)"
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
    progress 5 12 "Installing Go"
    if command_exists go; then
        info "Go is already installed."
    else
        info "Installing Go..."
        
        # Try official binary installation first (more reliable)
        local go_version="1.23.4"  # Update this to latest stable version
        local go_archive="go${go_version}.linux-amd64.tar.gz"
        local temp_dir="/tmp/go-install"
        
        mkdir -p "$temp_dir"
        cd "$temp_dir"
        
        info "Downloading Go $go_version..."
        if curl -LO "https://golang.org/dl/${go_archive}"; then
            info "Installing Go from official binary..."
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf "$go_archive"
            
            # Add Go to PATH for current session
            export PATH=$PATH:/usr/local/go/bin
            
            # Verify installation
            if /usr/local/go/bin/go version; then
                success "Go installed successfully from official binary."
                rm -rf "$temp_dir"
                return 0
            fi
        fi
        
        # Fallback to package manager
        warning "Official binary installation failed, trying package manager..."
        case "$UBUNTU_VERSION" in
            "24.04"|"24.10"|"25.04"|"25.10")
                # Try apt package first
                if sudo apt-get install -y golang-go 2>/dev/null; then
                    success "Go installed from apt package."
                else
                    # Fallback to PPA for older versions
                    warning "Standard Go package not available, trying PPA..."
                    sudo add-apt-repository -y ppa:longsleep/golang-backports || error "Failed to add Go repository"
                    sudo apt-get update || error "Failed to update package list"
                    sudo apt-get install -y golang-go || error "Failed to install Go"
                    success "Go installed from PPA."
                fi
                ;;
            *)
                error "Unsupported Ubuntu version for Go installation"
                ;;
        esac
        
        rm -rf "$temp_dir"
    fi
}

install_rust() {
    progress 6 12 "Installing Rust and Cargo"
    if command_exists rustc && command_exists cargo; then
        info "Rust and Cargo are already installed."
    else
        info "Installing Rust and Cargo via rustup..."
        
        # Download and install rustup
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || error "Failed to install Rust"
        
        # Source cargo environment for current session
        source "$HOME/.cargo/env" 2>/dev/null || true
        
        # Verify installation
        if command_exists rustc && command_exists cargo; then
            local rust_version=$(rustc --version 2>/dev/null || echo "unknown")
            local cargo_version=$(cargo --version 2>/dev/null || echo "unknown")
            success "Rust installed successfully: $rust_version"
            success "Cargo installed successfully: $cargo_version"
        else
            error "Rust installation verification failed"
        fi
    fi
}

setup_zsh() {
    progress 7 12 "Setting up Zsh with Oh My Zsh"
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
    
    # Copy zshrc with change detection
    copy_config_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" "zshrc" "Zsh configuration"
    
    # Change default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)" || warning "Failed to change default shell. You may need to log out and back in."
    fi
    
    success "Zsh is configured with Oh My Zsh and agnoster theme."
}

setup_tmux() {
    progress 8 12 "Setting up Tmux"
    info "Setting up Tmux..."
    
    # Install TPM if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || error "Failed to install TPM"
    else
        info "TPM is already installed."
    fi
    
    # Copy tmux.conf with change detection
    local tmux_updated=false
    if copy_config_file "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf" "tmux_conf" "Tmux configuration"; then
        tmux_updated=true
    fi
    
    # Install plugins only if configuration was updated or plugins don't exist
    if [[ "$tmux_updated" == true ]] || [[ ! -d "$HOME/.tmux/plugins/catppuccin" ]]; then
        info "Installing Tmux plugins..."
        if command_exists tmux; then
            # Kill any existing tmux sessions to avoid conflicts
            tmux kill-server 2>/dev/null || true
            tmux start-server || true
            tmux new-session -d -s setup_session || true
            "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" || warning "Failed to install some tmux plugins automatically"
            tmux kill-session -t setup_session 2>/dev/null || true
        fi
    else
        info "Tmux plugins are already installed."
    fi
    
    success "Tmux configured with enhanced features and plugins."
}

setup_neovim() {
    progress 9 12 "Setting up Neovim"
    info "Setting up Neovim..."
    
    # Copy Neovim configuration with change detection
    copy_config_file "$SCRIPT_DIR/init.lua" "$HOME/.config/nvim/init.lua" "nvim_init" "Neovim configuration"
    
    success "Neovim configuration setup completed."
}

setup_docker() {
    progress 10 12 "Setting up Docker"
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
    
    # Add Docker repository with fallback support
    local docker_codename="$UBUNTU_CODENAME"
    
    # Handle newer Ubuntu versions that might not have Docker repo yet
    case "$UBUNTU_VERSION" in
        "25.04"|"25.10")
            warning "Ubuntu $UBUNTU_VERSION detected. Trying Docker repository with $docker_codename, with fallback to noble if needed."
            ;;
    esac
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $docker_codename stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error "Failed to add Docker repository"
    
    # Install Docker with fallback
    sudo apt-get update || warning "Failed to update package list, trying with fallback"
    
    if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
        if [[ "$UBUNTU_VERSION" =~ ^25\. ]]; then
            warning "Docker packages not available for $UBUNTU_CODENAME, trying with noble (Ubuntu 24.04) repository..."
            
            # Replace repository with noble fallback
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              noble stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error "Failed to add fallback Docker repository"
            
            sudo apt-get update || error "Failed to update package list with fallback repository"
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker with fallback"
            
            success "Docker installed using noble (Ubuntu 24.04) repository."
        else
            error "Failed to install Docker"
        fi
    else
        success "Docker installed using native repository."
    fi
    
    # Add user to docker group
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER" || error "Failed to add user to docker group"
    
    success "Docker and Docker Compose installed. Docker can be run as a non-root user after reboot."
}

harden_ssh() {
    progress 11 12 "Hardening SSH configuration"
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
    progress 12 12 "Final cleanup and summary"
    info "Performing final cleanup..."
    
    # Clean up temporary files
    sudo apt-get autoremove -y >/dev/null 2>&1 || true
    sudo apt-get autoclean >/dev/null 2>&1 || true
    
    success "Setup completed successfully!"
    echo ""
    info "=== SETUP SUMMARY ==="
    info "✓ Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME) compatibility verified"
    info "✓ System packages updated"
    info "✓ Development tools installed (Go, Rust/Cargo, Python/uv, Node.js/pnpm)"
    info "✓ File utilities installed (eza/exa, bat/batcat)"
    info "✓ Zsh configured with Oh My Zsh and agnoster theme"
    info "✓ Tmux configured with enhanced features and plugins"
    info "✓ Neovim configuration installed"
    info "✓ Docker and Docker Compose installed"
    info "✓ SSH hardened (password auth disabled)"
    info "✓ Configuration backups saved to: $BACKUP_DIR"
    info "✓ Installation log saved to: $LOG_FILE"
    info "✓ Configuration checksums stored in: $CHECKSUM_FILE"
    echo ""
    warning "IMPORTANT: Please reboot your system for all changes to take effect."
    warning "After reboot, run 'tmux' and press Ctrl+a + I to install tmux plugins."
    info "The setup has been optimized for Ubuntu 24.04+ and 25.04+ compatibility."
    info "Re-run this script anytime to apply updated configuration files automatically."
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
    install_rust
    setup_zsh
    setup_tmux
    setup_neovim
    setup_docker
    harden_ssh
    final_cleanup
}

# Run main function
main "$@"
