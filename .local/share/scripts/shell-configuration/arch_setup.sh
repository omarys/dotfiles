#!/usr/bin/bash

# Package update
sudo pacman -Syyu

# Pacman install dependencies
sudo pacman -S base-devel npm nodejs wl-clipboard flatpak sqlite3 direnv \
  shfmt shellcheck tidy curl unzip aspell aspell-en stow git zsh \
  autoconf mpv feh opensc kitty neovim ccid acsccid tmux pcsc-perl \
  pcsc-tools discord keepassxc steam

sudo npm install -g neovim marked js-beautify stylelint

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rust alternatives install
~/.cargo/bin/cargo install bottom lsd rm-improved fd-find bat \
  zoxide cargo-update tree-sitter-cli editorconfig starship git-delta
~/.cargo/bin/cargo install ripgrep --features pcre2
~/.cargo/bin/cargo install --locked yazi-fm yazi-cli

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Lazyvim setup
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm ~/.config/nvim/.git

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
openssl pkcs7 -in ~/Downloads/certs/Certificates_PKCS7_v5_14_DoD/certificates_pkcs7_v5_14_dod_der.p7b \
  -inform der -print_certs -out ~/Downloads/certs/dod_CAs.pem
sudo trust anchor --store dod_CAs.pem

# Add CAC reader capability ofr Chrome
cd ~
modutil -dbdir sql:.pki/nssdb/ -add "CAC Module" -libfile /usr/lib64/onepin-opensc-pkcs11.so

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install OMZ & Auto Suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
