# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$HOME/.config/emacs/bin:$PATH"
fi
export PATH

export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_TTY=1"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

alias cat="bat"
alias find="fd"
alias ls="lsd"
alias rm="rip"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias vid="mpv (wl-paste)"
alias xvid="mpv (xclip -o)"
alias novid="mpv (wl-paste) --no-video"
alias xnovid="mpv (xclip -o) --no-video"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias cargup="rustup update; cargo install-update -a"
alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
alias xclipkey="xclip ~/.ssh/id_ed25519.pub"
alias pyt="poetry run python -m unittest discover"
alias tuir="tuir --enable-media"
alias mc="mullvad connect"
alias md="mullvad disconnect"
alias gonews="w3m gopher://gopher.leveck.us:70"
alias goredd="w3m gopher://gopherddit.com:70"
alias goworld="w3m gopher://gopher.floodgap.com/1/world"
alias gorec="w3m gopher://fld.gp:70"
alias gomisc="w3m gopher://mozz.us:70"
alias clr="clear"

unset rc
. "$HOME/.cargo/env"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
