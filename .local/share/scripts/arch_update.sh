#!/usr/bin/bash

# Package update
sudo pacman -Syyu

# Pacman install dependencies
sudo pacman -S base-devel npm nodejs wl-clipboard flatpak sqlite3 direnv \
	shfmt shellcheck tidy curl unzip aspell aspell-en stow git zsh \
	autoconf mpv feh opensc alacritty
# sudo nala install build-essential opensc libpcsc-perl libpcsclite-dev \
# 	libpcsclite1 libdbus-1-dev pcsc-tools cmake pkg-config libfreetype6-dev \
# 	libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 tmux \
# 	aspell aspell-en xclip ninja-build gettext cmake unzip curl libssl-dev \
# 	stow git zsh autoconf texinfo libx11-dev libmagickwand-dev libxaw7-dev \
# 	libgccjit-13-dev libgif-dev libjansson4 libjansson-dev gnutls-bin \
# 	libtree-sitter-dev libncurses-dev libtinfo-dev libharfbuzz-dev \
# 	libacl1-dev libxinerama-dev libxcb-xinerama0-dev sbcl sqlite3 \
# 	steam-devices mpv feh python3-pip libtool-bin libtool xdotool graphviz \
# 	gnuplot editorconfig npm nodejs openjdk-19-jdk glslang-dev glslang-tools \
# 	clang-format direnv shfmt shellcheck tidy gnutls-dev texlive-latex-base \
# 	texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra flatpak \
# 	libnss3-tools syncthingtray-kde-plasma procps

# Editor dependencies install
pip install --user pipx --break-system-packages
pipx install poetry neovim lazygit wheel ansible black grip pyflakes isort \
	pipenv nose pytest

sudo npm install -g neovim marked js-beautify stylelint

# Flatpaks install
flatpak install org.keepassxc.KeePassXC com.discordapp.Discord \
	com.valvesoftware.Steam com.valvesoftware.Steam.Utility.steamtinkerlaunch \
	org.freedesktop.Platform.VulkanLayer.gamescope

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rust alternatives install
~/.cargo/bin/cargo install bottom lsd rm-improved fd-find bat \
	zoxide cargo-update tree-sitter-cli
~/.cargo/bin/cargo install ripgrep --features pcre2
~/.cargo/bin/cargo install --locked --force xplr

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim source code clone/build
# git clone https://github.com/neovim/neovim.git ~/Dev/neovim
# cd ~/Dev/neovim
# make CMAKE_BUILD_TYPE=RelWithDebInfo
# cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# Lazyvim setup
# git clone https://github.com/LazyVim/starter ~/.config/nvim
# rm ~/.config/nvim/.git

# Emacs source code clone/build
# git clone https://git.savannah.gnu.org/git/emacs.git ~/Dev/emacs
# cd ~/Dev/emacs
# git checkout emacs-29
# git pull
# ./autogen.sh
# ./configure --with-cairo --with-modules --without-compress-install --with-gnutls --with-mailutils --with-native-compilation \
# 	--with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft \
# 	--with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local
# make -j$(nproc)
# sudo make install

# Doom Emacs setup
# git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
# ~/.config/emacs/bin/doom install

# Clean up Thunar - this was an old fix for the XFCE file manager
/usr/bin/rm -rfv ~/.cache/thumbnails

# Install mangal
curl -sSL mangal.metafates.one/install | sh

# Fonts!
cd ~/Downloads
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip
mkdir ~/.local/share/fonts
unzip CascadiaCode.zip -d ~/.local/share/fonts/

# Certificates
curl -LO https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip
mkdir ~/Downloads/certs
unzip unclass-certificates_pkcs7_DoD.zip -d ~/Downloads/certs
openssl pkcs7 -in ~/Downloads/certs/certificates_pkcs7_v5_13_dod_der.p7b \
	-inform der -print_certs -out ~/Downloads/certs/dod_CAs.pem
sudo cp ~/Downloads/certs/dod_CAs.pem /usr/local/share/ca-certificates/dod_CAs.crt
sudo update-ca-certificates

# Enable Chrome CAC card use
cd ~ && modutil -dbdir sql:.pki/nssdb -add "CAC Module" \
	-libfile /usr/lib/x86_64-linux-gnu/onepin-opensc-pkcs11.so

# Oh-my-zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k setup
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
