# ~/.zshrc - Optimized for speed, security and macOS (Apple Silicon / Intel)

# -----------------------------
# Security First - NEVER put tokens in .zshrc
# -----------------------------
# Instead, use:
#   echo 'export GITHUB_TOKEN="ghp_..."' >> ~/.zsh_secrets
#   echo 'export FLUTTERFLOW_API_TOKEN="..."' >> ~/.zsh_secrets
#   source ~/.zsh_secrets 2>/dev/null
#
# Or better: use `gh auth login` and direnv/keychain

# -----------------------------
# Path Setup (deduplicated, ordered)
# -----------------------------
typeset -U PATH path fpath cdpath manpath
path=(
  $HOME/.local/bin
  $HOME/.pub-cache/bin
  $HOME/.bun/bin
  /opt/homebrew/opt/ruby/bin
  /opt/homebrew/bin
  /usr/local/bin
  $HOME/work/projects/scripts
  $path
)

# FVM (Flutter Version Management) - only if present
if [[ -d "$HOME/fvm/default/bin" ]]; then
  path=("$HOME/fvm/default/bin" $path)
fi

export PATH

# -----------------------------
# History Config (100x settings)
# -----------------------------
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt EXTENDED_HISTORY          # timestamp in history
setopt INC_APPEND_HISTORY        # append immediately
setopt SHARE_HISTORY             # share across sessions
setopt HIST_IGNORE_DUPS          # ignore consecutive dups
setopt HIST_IGNORE_SPACE         # ignore commands starting with space
setopt HIST_REDUCE_BLANKS        # clean up whitespace
setopt HIST_VERIFY               # verify before executing from history

# -----------------------------
# Oh My Zsh Base
# -----------------------------
export ZSH="$HOME/.oh-my-zsh"

# Minimal + fast theme (agnoster is fine with Starship, but we disable its prompt)
ZSH_THEME="robbyrussell"

# Fast plugins only - these are enough for 95% of users
plugins=(
  git
  z
  fzf           # if you have fzf installed
  docker
  kubectl
  aws
  gh
)

# Disable auto-update (too noisy, use manual or brew)
zstyle ':omz:update' mode disabled

# Case-insensitive completion + fuzzy matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# -----------------------------
# Source Oh My Zsh (early, but minimal)
# -----------------------------
source $ZSH/oh-my-zsh.sh

# -----------------------------
# Starship Prompt (replaces Oh My Zsh theme)
# -----------------------------
eval "$(starship init zsh)"

# -----------------------------
# Tools & Lazy Loading
# -----------------------------

# NVM - cache brew prefix for speed
export NVM_DIR="$HOME/.nvm"
_nvm_brew_prefix="$(brew --prefix nvm 2>/dev/null)"

nvm() {
  unset -f nvm node npm bun
  [[ -s "$_nvm_brew_prefix/nvm.sh" ]] && source "$_nvm_brew_prefix/nvm.sh" --no-use
  nvm "$@"
}

node() {
  unset -f node
  [[ -s "$_nvm_brew_prefix/nvm.sh" ]] && source "$_nvm_brew_prefix/nvm.sh" --no-use
  nvm use default 2>/dev/null || nvm use --lts
  node "$@"
}

npm() {
  unset -f npm
  [[ -s "$_nvm_brew_prefix/nvm.sh" ]] && source "$_nvm_brew_prefix/nvm.sh" --no-use
  nvm use default 2>/dev/null || nvm use --lts
  npm "$@"
}

# Bun (already in PATH, completions optional)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pyenv - lazy init
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init - --no-rehash)"
  eval "$(pyenv virtualenv-init -)"
fi

# fzf - already loaded by Oh My Zsh plugin above, skip redundant source
# Enhanced fzf settings
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='
    --height 40% --reverse --border
    --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
fi

# Ruby / RVM (only if you use it)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# -----------------------------
# Modern CLI Tools (install via: brew install eza bat fd ripgrep)
# -----------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto"
  alias l="eza -lah --icons=auto --git"
  alias ll="eza -lh --icons=auto --git"
  alias la="eza -a --icons=auto"
  alias lt="eza --tree --level=2 --icons=auto"
  alias lta="eza --tree --level=2 --icons=auto -a"
else
  alias l="ls -lah"
  alias ll="ls -lh"
  alias la="ls -a"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
  alias catp="bat"  # with pager
fi

if command -v fd >/dev/null 2>&1; then
  alias find="fd"
fi

# ripgrep is preferred, 'rg' is default command

# -----------------------------
# Aliases (clean & useful)
# -----------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias g="git"
alias gs="git status"
alias gss="git status -s"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias glg="git log --oneline --graph --decorate"
alias glga="git log --oneline --graph --decorate --all"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gbd="git branch -d"
alias gm="git merge"
alias gr="git rebase"
alias gri="git rebase -i"
alias gst="git stash"
alias gstp="git stash pop"

alias q="exit"
alias c="clear"
alias h="history"
alias hg="history | grep"

# YouTube downloader
alias ytdl="yt-download.sh"

alias v="$EDITOR"
alias vim="$EDITOR"
alias nvim="$EDITOR"

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -p"
alias clauded="claude --dangerously-skip-permissions"

# Network & system
alias myip="curl -s ifconfig.me"
alias ports="lsof -i -P -n | grep LISTEN"
alias cpu="top -o cpu"
alias mem="top -o mem"
# python
alias penv="python -m venv .venv"
vnew() {
  python3 -m venv .venv
  source .venv/bin/activate
}

# Quick temp dir
tempe() {
  local dir
  if [[ $# -eq 1 ]]; then
    dir=$(mktemp -d -t "$1.XXXXXX")
    mkdir -p "$dir/$1"
    cd "$dir/$1"
  else
    dir=$(mktemp -d)
    cd "$dir"
  fi
  pwd
}

# cd to git root
alias groot='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'

# Fix common typos
alias sl="ls"
alias gut="git"
alias :q="exit"
alias cd..="cd .."

# -----------------------------
# 100x Productivity Functions
# -----------------------------

# Fast project directory switching (customize paths)
proj() {
  local base_dirs=("$HOME/code" "$HOME/work/projects" "$HOME/projects")
  local projects=()

  for dir in $base_dirs; do
    [[ -d "$dir" ]] && projects+=("$dir"/*(N/))
  done

  if [[ -z "$1" ]]; then
    # Use fzf if available
    if command -v fzf >/dev/null 2>&1; then
      local selected=$(printf '%s\n' "${projects[@]}" | fzf --height=40% --reverse)
      [[ -n "$selected" ]] && cd "$selected"
    else
      printf '%s\n' "${projects[@]}"
    fi
  else
    # Fuzzy match project name
    local match=$(printf '%s\n' "${projects[@]}" | grep -i "$1" | head -1)
    [[ -n "$match" ]] && cd "$match" || echo "No project matching '$1'"
  fi
}

# Quick git commit with message (unalias first if Oh My Zsh defines it)
unalias gcam 2>/dev/null
gcam() {
  git add -A && git commit -m "$*"
}

# Git branch cleanup (delete merged branches)
gbclean() {
  git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Create branch with kp/ prefix per your instructions
gcbkp() {
  git checkout -b "kp/$1"
}

# Find process on port
port() {
  lsof -i ":$1"
}

# Kill process on port
killport() {
  lsof -ti ":$1" | xargs kill -9
}

# Extract archives (any format)
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick backup of file/dir
backup() {
  cp -r "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# fzf enhanced cd (if fzf installed)
if command -v fzf >/dev/null 2>&1; then
  cdf() {
    local dir
    dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
  }

  # fzf git log browser
  fgl() {
    git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' --preview-window=right:60%
  }
fi

# Quick note taking
note() {
  local notes_dir="$HOME/.notes"
  mkdir -p "$notes_dir"
  local note_file="$notes_dir/$(date +%Y-%m-%d).md"

  if [[ -n "$*" ]]; then
    echo "- $(date +%H:%M) $*" >> "$note_file"
  else
    ${EDITOR:-vim} "$note_file"
  fi
}

# Docker cleanup
dclean() {
  docker system prune -af --volumes
}

# Show disk usage of current dir, sorted
dux() {
  du -sh * | sort -h
}

# -----------------------------
# Secrets (optional, secure)
# -----------------------------
# Create ~/.zsh_secrets (add to .gitignore!)
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# -----------------------------
# Final: your custom try.rb thing (fixed)
# -----------------------------
(( ${+functions[try]} )) || eval "$(ruby ~/.local/try.rb init ~/src/tries 2>/dev/null)"

# Done!
# bun completions
[ -s "/Users/karthikp/.bun/_bun" ] && source "/Users/karthikp/.bun/_bun"
