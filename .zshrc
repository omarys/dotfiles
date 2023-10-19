if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.zig/bin:$HOME/go/bin:$HOME/.config/emacs/bin:/usr/local/bin:$PATH

# default browser
export BROWSER=/usr/bin/firefox

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_TTY=1"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  ansible
  common-aliases
  cp
  docker
  dotnet
  emacs
  extract
  fd
  git
  golang
  npm
  poetry
  python
  ripgrep
  rust
  tmux
  vagrant
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Standard aliases
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias cat="bat"
alias find="fd"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias cargup="rustup update; cargo install-update -a"
alias pyt="poetry run python -m unittest discover"
alias gonews="w3m gopher://gopher.leveck.us:70"
alias goredd="w3m gopher://gopherddit.com:70"
alias goworld="w3m gopher://gopher.floodgap.com/1/world"
alias gorec="w3m gopher://fld.gp:70"
alias gomisc="w3m gopher://mozz.us:70"
alias gitc="git clone $(xclip -o -selection clipboard)"
alias clr="clear"
alias upp="flatpak update -y; cargup; doom up; doom sync; doom purge;"
alias zzz="exit"

# Conditional aliases
type ag >/dev/null 2>&1 && alias grep=ag
type pacman >/dev/null 2>&1 && alias in="sudo pacman -S"
type pacman >/dev/null 2>&1 && alias up="sudo pacman -Syyu"
type apt >/dev/null 2>&1 && alias in="sudo apt install"
type apt >/dev/null 2>&1 && alias up="apt update; sudo apt upgrade -y"
type xclip >/dev/null 2>&1 && alias clipkey="xclip -sel c < ~/.ssh/id_ed25519.pub"
type wl-copy >/dev/null 2>&1 && alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
type xclip >/dev/null 2>&1 && alias vid="mpv \"$(xclip -o)\""
type wl-paste >/dev/null 2>&1 && alias vid="mpv \"$(wl-paste)\""
type xclip >/dev/null 2>&1 && alias novid="mpv \"$(xclip -o)\" --no-video"
type wl-paste >/dev/null 2>&1 && alias novid="mpv \"$(wl-paste)\" --no-video"
type xclip >/dev/null 2>&1 && alias cl="git clone \"$(xclip -o)\""
type wl-paste >/dev/null 2>&1 && alias cl="git clone \"$(wl-paste)\""
type xplr >/dev/null 2>&1 && alias xx="xplr"

if [[ -f ~/.cmd ]]; then
  alias cmd="cat ~/.cmd"
fi

eval "$(zoxide init zsh)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
