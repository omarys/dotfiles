. ~/.config/fish/alias.fish

# Tell Vagrant to use virtualbox as it's default provider.
set -x VAGRANT_DEFAULT_PROVIDER virtualbox

# make nvim the default editor
set -x EDITOR lvim

# make nvim usable with git
set -x GIT_EDITOR lvim

# Silence fish greeting
set -g fish_greeting ''

# enable nerd fonts
set -g theme_nerd_fonts yes

# swap esc and caps
# setxkbmap -option caps:swapescape

# start_agent for ssh
setenv SSH_ENV $HOME/.ssh/environment

if test -d $HOME/.local/bin/
    set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.emacs.d/bin $PATH
end

if test -d /var/lib/flatpak/
    set -gx XDG_DATA_DIRS "/home/omary/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share/:/usr/local/share/:/usr/share/"
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

# function start_agent
#     if [ -n "$SSH_AGENT_PID" ]
#             ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
#             if [ $status -eq 0 ]
#                 test_identities
#             end
#     else
#             if [ -f $SSH_ENV ]
#                 . $SSH_ENV > /dev/null
#             end
#         ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
#         if [ $status -eq 0 ]
#             test_identities
#         else
#             echo "Initializing new SSH agent ..."
#             ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
#             echo "succeeded"
#         chmod 600 $SSH_ENV
#         . $SSH_ENV > /dev/null
#             ssh-add
#     end
#     end
# end

# function test_identities
#     ssh-add -l | grep "The agent has no identities" > /dev/null
#     if [ $status -eq 0 ]
#         ssh-add
#         if [ $status -eq 2 ]
#             start_agent
#         end
#     end
# end

# function fish_title
#     if [ $_ = 'fish' ]
#     echo (prompt_pwd)
#     else
#         echo $_
#     end
# end

starship init fish | source
