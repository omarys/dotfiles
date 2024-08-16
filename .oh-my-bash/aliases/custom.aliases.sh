alias cat="bat"
alias find="fd"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias vid="mpv (wl-paste)"
alias novid="mpv (wl-paste) --no-video"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias vibe="mpv \"https://music.youtube.com/playlist?list=PLIwxj45VjSXUJr34vOVE2q0EUFqO7OO-3\" --no-video --loop-playlist"
alias cargup="rustup update; cargo install-update -a"
alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
alias pyt="poetry run python -m unittest discover"
alias mc="mullvad connect"
alias md="mullvad disconnect"
alias clr="clear"
alias zzz="exit"
alias upp="rustup update; cargo install-update -a; \
  doom up; doom sync; doom gc;"
alias cleana="sed -i -e \"s/\r//g\""
alias cleanb="sed -i -e \"s/\e\[[0-9;]*m//g\""

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
type dnf5 >/dev/null 2>&1 && alias up="sudo dnf5 upgrade -y"

type wl-copy >/dev/null 2>&1 && alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
type wl-paste >/dev/null 2>&1 && alias vid="mpv $(wl-paste)"
type wl-paste >/dev/null 2>&1 && alias novid="mpv $(wl-paste) --no-video"

type nvim >/dev/null 2>&1 && alias bashconfig="nvim ~/.bashrc"
type nvim >/dev/null 2>&1 && alias aliasconfig="nvim ~/.oh-my-bash/aliases/custom.aliases.sh"

type tree >/dev/null 2>&1 && alias treee="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

if [[ -x mvn ]]; then
  alias mci='mvn clean install'
  alias mi='mvn install'
  alias mcp='mvn clean package'
  alias mp='mvn package'
  alias mrprep='mvn release:prepare'
  alias mrperf='mvn release:perform'
  alias mrrb='mvn release:rollback'
  alias mdep='mvn dependency:tree'
  alias mpom='mvn help:effective-pom'
  alias mcisk='mci -Dmaven.test.skip=true'
  alias mcpsk='mcp -Dmaven.test.skip=true'
fi

if [[ -x curl ]]; then
  # follow redirects
  alias cl='curl -L'
  # follow redirects, download as original name
  alias clo='curl -L -O'
  # follow redirects, download as original name, continue
  alias cloc='curl -L -C - -O'
  # follow redirects, download as original name, continue, retry 5 times
  alias clocr='curl -L -C - -O --retry 5'
  # follow redirects, fetch banner
  alias clb='curl -L -I'
  # see only response headers from a get request
  alias clhead='curl -D - -so /dev/null'
fi

if [[ -f ~/.cmd ]]; then
  alias cmd="cat ~/.cmd"
fi
