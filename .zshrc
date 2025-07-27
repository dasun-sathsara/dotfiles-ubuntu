# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which theme is loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of plugins.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Aliases ---
# File listing - prefer eza over exa, fallback to ls
if command -v eza &> /dev/null; then
    alias ls='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias ll='eza -l --icons --git'
elif command -v exa &> /dev/null; then
    alias ls='exa -l --icons --git'
    alias la='exa -la --icons --git'
    alias ll='exa -l --icons --git'
else
    alias ls='ls -l --color=auto'
    alias la='ls -la --color=auto'
    alias ll='ls -l --color=auto'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git shortcuts
alias g='git'
alias gp='git pull'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'

# Better cat - prefer bat over batcat
if command -v bat &> /dev/null; then
    alias cat='bat'
elif command -v batcat &> /dev/null; then
    alias cat='batcat'
fi

# Editor
alias vim='nvim'
alias vi='nvim'

# Docker shortcuts
alias dps='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'

# pnpm
export PNPM_HOME="/home/user/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
