# Zsh Configuration with Oh My Zsh
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - Using Powerlevel10k for a modern, fast prompt
ZSH_THEME="powerlevel10k/powerlevel10k"

# Powerlevel10k instant prompt - should stay close to the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh settings
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="false"
DISABLE_UPDATE_PROMPT="false"
export UPDATE_ZSH_DAYS=13

# Uncomment if you want to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files under VCS as dirty (speeds up large repos)
DISABLE_UNTRACKED_FILES_DIRTY="false"

# History configuration
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Plugins to load
# Standard plugins: $ZSH/plugins/
# Custom plugins: $ZSH_CUSTOM/plugins/
plugins=(
    git
    docker
    docker-compose
    sudo
    command-not-found
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fast-syntax-highlighting
    zsh-history-substring-search
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# User Configuration
# ============================================================================

# Preferred editor
export EDITOR='vim'
export VISUAL='vim'

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Path additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ============================================================================
# Aliases
# ============================================================================

# General aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias reload="source ~/.zshrc"

# Better ls with exa (if installed)
if command -v exa &> /dev/null; then
    alias ls="exa --icons"
    alias ll="exa -alh --icons"
    alias la="exa -a --icons"
    alias lt="exa --tree --icons"
else
    alias ll="ls -alh"
    alias la="ls -A"
fi

# Better cat with bat (if installed)
if command -v bat &> /dev/null; then
    alias cat="bat"
fi

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"

# Fedora package management
alias update="sudo dnf update"
alias install="sudo dnf install"
alias remove="sudo dnf remove"
alias search="dnf search"

# Sway related
alias sway-reload="swaymsg reload"
alias waybar-reload="killall waybar && waybar &"

# System
alias ports="netstat -tulanp"
alias mem="free -h"
alias disk="df -h"

# Docker
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dex="docker exec -it"

# Safety nets
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ============================================================================
# Key bindings
# ============================================================================

# Use vim keybindings (optional - comment out if you prefer emacs mode)
# bindkey -v

# History search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Better command line editing
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey '^[[3;5~' kill-word         # Ctrl+Delete

# ============================================================================
# Completions
# ============================================================================

# Load zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Enable completion system
autoload -U compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colorful completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================================
# Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
