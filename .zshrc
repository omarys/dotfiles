#! /usr/bin/env zsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.zig/bin:$HOME/.config/emacs/bin:$HOME/go/bin:/usr/local/bin:$PATH:$HOME/.ghcup

# default browser
export BROWSER=/usr/bin/firefox

export EDITOR='nvim'

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_TTY=1"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# zstyle ':omz:update' frequency 7

DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  ansible
  archlinux
  aws
  brew
  # bun
  colorize
  common-aliases
  # composer
  cp
  docker
  docker-compose
  dnf
  # conda
  extract
  fnm
  fzf
  gem
  git
  # git-flow
  gitignore
  golang
  kubectl
  # laravel
  man
  mani
  minikube
  mvn
  node
  npm
  nvm
  opentofu
  # perl
  # podman
  pre-commit
  python
  rust
  spring
  ssh
  starship
  sudo
  systemd
  tmux
  uv
  # yarn
  zoxide
  zsh-autosuggestions
)

source "$ZSH"/oh-my-zsh.sh

export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Standard aliases
alias zshconfig="nvim ~/.zshrc"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias cargup="rustup update; cargo install-update -a"
alias clr="clear"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias vibe="mpv \"https://music.youtube.com/playlist?list=PLIwxj45VjSXUJr34vOVE2q0EUFqO7OO-3\" --no-video --loop-playlist"
alias zzz="exit"
alias gcn="git commit --no-verify"
alias ms="minikube start"
alias md="minikube delete"
alias dsh="docker run -it --entrypoint /bin/sh"
# alias psh="podman run -it --entrypoint /bin/sh"
alias bigvim="nvim -u ~/.dotfiles/.config/nvim/large-file.vim"

# Conditional aliases
type nala >/dev/null 2>&1 && alias se="nala search"
type nala >/dev/null 2>&1 && alias in="sudo nala install"
type nala >/dev/null 2>&1 && alias up="flatpak update -y; \
  sudo nala upgrade --assume-yes;"

type pacman >/dev/null 2>&1 && alias upp="sudo pacman -Syyu; rustup update; cargo install-update -a; brew up; brew upgrade; ya pkg upgrade; flatpak update;"
type pacman >/dev/null 2>&1 && alias se="pacman -Ss"
type pacman >/dev/null 2>&1 && alias in="sudo pacman -S"

type dnf >/dev/null 2>&1 && alias upp="sudo dnf -y update --refresh; rustup update; cargo install-update -a; brew up; brew upgrade; ya pkg upgrade; flatpak update;"
type dnf >/dev/null 2>&1 && alias se="dnf search"
type dnf >/dev/null 2>&1 && alias in="sudo dnf -y install"

type tree >/dev/null 2>&1 && alias treee="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

type uv >/dev/null 2>&1 && alias uvr="uv export --no-emit-workspace --no-dev --no-annotate --no-header --no-hashes --output-file src/requirements.txt"

type wl-paste >/dev/null 2>&1 && alias ggit='git clone $(wl-paste)'
type wl-copy >/dev/null 2>&1 && alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
type wl-paste >/dev/null 2>&1 && alias vid='mpv $(wl-paste)'
type wl-paste >/dev/null 2>&1 && alias novid='$(wl-paste) --no-video'

type navi >/dev/null 2>&1 && alias cheat="navi --cheatsh"

type uv >/dev/null 2>&1 && alias uvr="uv export --no-emit-workspace --no-dev --no-annotate --no-header --no-hashes --output-file src/requirements.txt"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd" || exit
	fi
	rm -f -- "$tmp"
}

function gitfind() {
  find . -type d -name ".git" -print0 | while IFS= read -r -d $'\0' dir; do
    (echo "$dir" && cd "$dir/.." && git pull)
  done
}

function gitfd() {
  fd -t d -H .git | while read -r repo; do
    (echo "$repo" && cd "$repo/.." && ggl)
  done
}

if [[ -f ~/.cht ]]; then
  alias cht="cat ~/.cht"
fi

bindkey '^ ' autosuggest-accept

. "$HOME/.cargo/env"
eval "$(mcfly init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(navi widget zsh)"
export FZF_CTRL_R_OPTS="
  --reverse
  --cycle
  --info=right
  --color header:italic
  --header 'alt+s (pet new)'
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind '?:toggle-preview'
  --bind 'alt-s:execute(pet new --tag {2..})+abort'"
export PATH="$PATH:$HOME/.rvm/bin"
# export AWS_VAULT_BACKEND=pass


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/home/omary/.opam/opam-init/init.zsh' ]] || source '/home/omary/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/share/../bin/env"
