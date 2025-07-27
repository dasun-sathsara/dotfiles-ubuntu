# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which theme is loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of plugins.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Aliases ---
alias ls='exa -l --icons --git'
alias la='exa -la --icons --git'
alias ll='exa -l --icons --git' [29]
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias g='git'
alias gp='git pull'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias cat='batcat' # on Ubuntu, bat is installed as batcat
alias vim='nvim'
alias vi='nvim'
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
