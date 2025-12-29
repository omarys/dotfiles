. ~/.config/fish/alias.fish

# make nvim the default editor
set -x EDITOR nvim

# make nvim usable with git
set -x GIT_EDITOR nvim

# Silence fish greeting
set -g fish_greeting ''

# enable nerd fonts
set -g theme_nerd_fonts yes

if test -d $HOME/.local/bin/
    set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.emacs.d/bin $PATH
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
# persistently add to path
# function add_to_path --description 'Persistently prepends paths to your PATH'
#   for path in $argv
#     if not contains $path $fish_user_paths
#       set --universal fish_user_paths $fish_user_paths $argv
#     end
#   end
# end

# Ensure fisherman and plugins are installed
# if not test -f $HOME/.config/fish/functions/fisher.fish
#   echo "==> Fisherman not found.  Installing."
#   curl -sLo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
#   fisher
# end

starship init fish | source
