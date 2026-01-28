alias bigvim="nvim -u ~/.dotfiles/.config/nvim/large-file.vim"
alias cargup="rustup update; cargo install-update -a"
alias clipkey="wl-copy < ~/.ssh/id_ed25519.pub"
alias clr="clear"
alias dsh="docker run -it --entrypoint /bin/sh"
alias fishconf="nvim ~/.config/fish/config.fish"
alias gcn="git commit --no-verify"
alias l="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lofi="mpv \"https://www.youtube.com/watch?v=jfKfPfyJRdk\" --no-video"
alias makessh="ssh-keygen -t ed25519 -C \"omaryscott@gmail.com\""
alias md="minikube delete"
alias ms="minikube start"
alias novid="mpv (wl-paste) --no-video"
alias vibe="mpv \"https://music.youtube.com/playlist?list=PLIwxj45VjSXUJr34vOVE2q0EUFqO7OO-3\" --no-video --loop-playlist"
alias vid="mpv (wl-paste)"
alias zzz="exit"

if using dnf
    alias in="sudo dnf install -y"
    alias up="sudo dnf upgrade -y"
    alias search="dnf search"
    alias remo="sudo dnf remove -y"
end
if using pacman
    alias in="sudo pacman -Syu"
    alias up="sudo pacman -Syyu"
    alias search="pacman -Ss"
    alias remo="sudo pacman -Rns"
end
if using kubectl
    alias k="kubectl"
    alias kgp="kubectl get pods"
    alias kgs="kubectl get svc"
    alias kgd="kubectl get deployments"
    alias kaf="kubectl apply -f"
    alias kdf="kubectl delete -f"
    alias kl="kubectl logs"
end
if using minikube
    alias mk="minikube"
    alias ms="minikube start"
    alias msp="minikube stop"
    alias md="minikube delete"
end
if using bat
    alias cat="bat"
end
if using fd
    alias find="fd"
end
if using lsd
    alias ls="lsd"
end
if using rip
    alias rm="rip"
end
if using z
    alias cd=z
end
# alias pissh="ssh pi@192.168.50.212"
