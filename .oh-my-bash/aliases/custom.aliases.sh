alias cat="bat"
alias find="fd"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias vid="mpv (wl-paste)"
alias novid="mpv (wl-paste) --no-video"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias cargup="rustup update; cargo install-update -a"
alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
alias pyt="poetry run python -m unittest discover"
alias mc="mullvad connect"
alias md="mullvad disconnect"
alias clr="clear"
alias zzz="exit"
alias upp="rustup update; cargo install-update -a; \
  doom up; doom sync; doom gc;"

type nala >/dev/null 2>&1 && alias se="nala search"
type nala >/dev/null 2>&1 && alias in="sudo nala install"
type nala >/dev/null 2>&1 && alias up="flatpak update -y; \
  sudo nala upgrade --assume-yes;"
type pacman >/dev/null 2>&1 && alias se="pacman -Ss"
type pacman >/dev/null 2>&1 && alias in="sudo pacman -S"
type pacman >/dev/null 2>&1 && alias up="flatpak update -y; \
  sudo pacman -Syyu;"

type dnf5 >/dev/null 2>&1 && alias dnf="dnf5"
type dnf5 >/dev/null 2>&1 && alias se="dnf5 search"
type dnf5 >/dev/null 2>&1 && alias in="sudo dnf5 install"
type dnf5 >/dev/null 2>&1 && alias up="dnf5 upgrade -y"

type wl-copy >/dev/null 2>&1 && alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
type wl-paste >/dev/null 2>&1 && alias vid="mpv $(wl-paste)"
type wl-paste >/dev/null 2>&1 && alias novid="mpv $(wl-paste) --no-video"

type nvim >/dev/null 2>&1 && alias bashconfig="nvim ~/.bashrc"
type nvim >/dev/null 2>&1 && alias aliasconfig="nvim ~/.oh-my-bash/aliases/custom.aliases.sh"

if [[ -f ~/.cmd ]]; then
  alias cmd="cat ~/.cmd"
fi
