#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Exit immediately if a command in a pipeline fails.
set -o pipefail

# --- Pretty Output Functions ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
    exit 1
}

# --- Initial Setup ---
info "Starting the development environment setup..."
sudo apt-get update && sudo apt-get upgrade -y
success "System packages updated and upgraded."

# --- Install Packages ---
info "Installing necessary packages..."
sudo apt-get install -y \
    neovim tmux zsh htop fastfetch exa \
    npm python3 python3-venv python3-pip \
    build-essential curl file git
success "Core packages installed."

# Install pnpm
info "Installing pnpm..."
npm install -g pnpm
success "pnpm installed."

# Install uv (Python package manager)
info "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.cargo/env"
success "uv installed." [17]

# Install Go
info "Installing Go..."
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get install -y golang-go
success "Go installed." [2, 3]

# --- Setup Zsh ---
info "Setting up Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions [11]
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting [5, 34, 39, 41]
cp .zshrc "$HOME/.zshrc"
chsh -s $(which zsh)
success "Zsh is set as the default shell and configured."

# --- Setup Tmux ---
info "Setting up Tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf "$HOME/.tmux.conf"
tmux start-server
tmux new-session -d
~/.tmux/plugins/tpm/scripts/install_plugins.sh
success "Tmux configured with TPM."

# --- Setup Neovim ---
info "Setting up Neovim..."
mkdir -p "$HOME/.config/nvim"
cp init.lua "$HOME/.config/nvim/init.lua"
success "Neovim configuration created."

# --- Setup Docker ---
info "Setting up Docker..."
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd -f docker
sudo usermod -aG docker $USER
newgrp docker
success "Docker and Docker Compose installed. Docker can be run as a non-root user." [7]

# --- Harden SSH ---
info "Hardening SSH configuration..."
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
success "Password authentication for SSH has been disabled."

success "All setup tasks are complete! Please reboot your system for all changes to take effect."
