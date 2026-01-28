. ~/.config/fish/alias.fish

set -x EDITOR nvim
set -x GIT_EDITOR nvim
set -g fish_greeting ''
set -g theme_nerd_fonts yes

if test -d $HOME/.local/bin/
    set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.config/emacs/bin $PATH
end

if test -d /var/lib/flatpak/
    set -gx XDG_DATA_DIRS "/home/omary/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share/:/usr/local/share/:/usr/share/"
end
set --global --export HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"

set --global --export HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar"

set --global --export HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew"

fish_add_path --global --move --path "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin"

if test -n "$MANPATH[1]"
    set --global --export MANPATH '' $MANPATH
end

if not contains "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH
    set --global --export INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH
end

starship init fish | source
