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

function fish_user_key_bindings
    bind ctrl-space accept-autosuggestion
end

function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    set cwd (/bin/cat -- $tmp)
    if test -s $tmp
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd -- $cwd
            commandline -f repaint # updates the prompt
        end
    end
    /bin/rm -f -- $tmp
end

function using
    type -q $argv[1]
end

. ~/.config/fish/alias.fish
starship init fish | source
