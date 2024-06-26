#!/usr/bin/bash

# Package update
sudo pacman -Syyu

# Pacman install dependencies
sudo pacman -S base-devel npm nodejs wl-clipboard flatpak sqlite3 direnv \
	shfmt shellcheck tidy curl unzip aspell aspell-en stow git zsh \
	autoconf mpv feh opensc alacritty emacs-wayland neovim pandoc \
	python-black python-pyflakes python-isort python-pipenv python-nose \
	python-pytest python-pipx ccid acsccid tmux pcsc-perl pcsc-tools \
	discord greetd keepassxc steam sway waybar fuzzle swaylock

pipx install poetry ansible

sudo npm install -g neovim marked js-beautify stylelint

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rust alternatives install
~/.cargo/bin/cargo install bottom lsd rm-improved fd-find bat \
	zoxide cargo-update tree-sitter-cli editorconfig starship
~/.cargo/bin/cargo install ripgrep --features pcre2
~/.cargo/bin/cargo install --locked --force xplr

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Lazyvim setup
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm ~/.config/nvim/.git

# Doom Emacs setup
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Clean up Thunar - this was an old fix for the XFCE file manager
/usr/bin/rm -rfv ~/.cache/thumbnails

# Install mangal
curl -sSL mangal.metafates.one/install | sh

# Fonts!
cd ~/Downloads
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Noto.zip
mkdir ~/.local/share/fonts
unzip CascadiaCode.zip -d ~/.local/share/fonts/
unzip Noto.zip -d ~/.local/share/fonts/

# Certificates
curl -LO https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip
mkdir ~/Downloads/certs
unzip unclass-certificates_pkcs7_DoD.zip -d ~/Downloads/certs
openssl pkcs7 -in ~/Downloads/certs/certificates_pkcs7_v5_13_dod_der.p7b \
	-inform der -print_certs -out ~/Downloads/certs/dod_CAs.pem
sudo trust anchor --store dod_CAs.pem

# Add CAC reader capability ofr Chrome
cd ~
modutil -dbdir sql:.pki/nssdb/ -add "CAC Module" -libfile /usr/lib64/onepin-opensc-pkcs11.so

# Wttr bar for weather
mkdir ~/Dev && cd ~/Dev
git clone https://github.com/bjesus/wttrbar.git
cd wttrbar
cargo build --release
cp target/release/wttrbar ~/.cargo/bin

# Oh-my-bash setup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
