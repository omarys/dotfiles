# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.zig/bin:$HOME/go/bin:$HOME/.config/emacs/bin:/usr/local/bin:$PATH

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
  aws
  brew
  bun
  colorize
  common-aliases
  composer
  cp
  docker
  docker-compose
  dnf
  conda
  extract
  fzf
  gem
  git
  git-flow
  gitignore
  golang
  laravel
  mvn
  node
  npm
  nvm
  opentofu
  perl
  podman
  poetry
  python
  rust
  spring
  ssh
  starship
  sudo
  systemd
  tmux
  uv
  zoxide
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Standard aliases
alias zshconfig="nvim ~/.zshrc"
alias find="fd"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias cargup="rustup update; cargo install-update -a"
alias pyt="poetry run python -m unittest discover"
alias clr="clear"
alias upp="rustup update; cargo install-update -a; brew up; brew upgrade;"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias vibe="mpv \"https://music.youtube.com/playlist?list=PLIwxj45VjSXUJr34vOVE2q0EUFqO7OO-3\" --no-video --loop-playlist"
alias zzz="exit"
alias gcn="git commit --no-verify"
alias podman="docker"

# Conditional aliases
type nala >/dev/null 2>&1 && alias se="nala search"
type nala >/dev/null 2>&1 && alias in="sudo nala install"
type nala >/dev/null 2>&1 && alias up="flatpak update -y; \
  sudo nala upgrade --assume-yes;"
type pacman >/dev/null 2>&1 && alias se="pacman -Ss"
type pacman >/dev/null 2>&1 && alias in="sudo pacman -S"
type pacman >/dev/null 2>&1 && alias up="flatpak update -y; \
  sudo pacman -Syyu; pipx upgrade-all;"

type dnf5 >/dev/null 2>&1 && alias se="dnf5 search"
type dnf5 >/dev/null 2>&1 && alias in="sudo dnf5 install"
type dnf5 >/dev/null 2>&1 && alias up="sudo dnf5 upgrade -y"

type tree >/dev/null 2>&1 && alias treee="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

type wl-paste >/dev/null 2>&1 && alias ggit="git clone \"$(wl-paste)\""
type wl-copy >/dev/null 2>&1 && alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
type wl-paste >/dev/null 2>&1 && alias vid="mpv $(wl-paste)"
type wl-paste >/dev/null 2>&1 && alias novid="mpv $(wl-paste) --no-video"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

if [[ -f ~/.cht ]]; then
  alias cht="cat ~/.cht"
fi

bindkey '^ ' autosuggest-accept

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/omary/.anaconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/omary/.anaconda/etc/profile.d/conda.sh" ]; then
        . "/home/omary/.anaconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/omary/.anaconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

. "$HOME/.cargo/env"
eval "$(mcfly init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="$PATH:$HOME/.rvm/bin"

# opam configuration
# [[ ! -r /home/omary/.opam/opam-init/init.zsh ]] || source /home/omary/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
