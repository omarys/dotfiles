#!/usr/bin/bash

# Package update
sudo apt update
sudo apt install nala
sudo nala upgrade

# Apt install dependencies
sudo nala install build-essential opensc libpcsc-perl libpcsclite-dev \
	libpcsclite1 libdbus-1-dev pcsc-tools cmake pkg-config libfreetype6-dev \
	libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 tmux \
	aspell aspell-en xclip ninja-build gettext cmake unzip curl libssl-dev \
	stow git zsh autoconf texinfo libx11-dev libmagickwand-dev libxaw7-dev \
	libgccjit-13-dev libgif-dev libjansson4 libjansson-dev gnutls-bin \
	libtree-sitter-dev libncurses-dev libtinfo-dev libharfbuzz-dev \
	libacl1-dev libxinerama-dev libxcb-xinerama0-dev sbcl sqlite3 \
	steam-devices mpv feh python3-pip libtool-bin libtool xdotool graphviz \
	gnuplot editorconfig npm nodejs openjdk-19-jdk glslang-dev glslang-tools \
	clang-format direnv shfmt shellcheck tidy gnutls-dev texlive-latex-base \
	texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra flatpak \
	python3.11-venv libnss3-tools syncthingtray-kde-plasma

# Editor dependencies install
pip install --user pipx --break-system-packages
pipx install poetry neovim lazygit wheel ansible black grip pyflakes isort \
	pipenv nose pytest

sudo npm install -g neovim marked js-beautify stylelint

# Flatpaks install
flatpak remote-add --if-not-exists \
	flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install org.keepassxc.KeePassXC com.discordapp.Discord \
	com.valvesoftware.Steam com.valvesoftware.Steam.Utility.steamtinkerlaunch \
	org.freedesktop.Platform.VulkanLayer.gamescope

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install alacritty
git clone https://github.com/alacritty/alacritty.git ~/Dev/alacritty
cd alacritty
cargo build --release --no-default-features --features=wayland
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# Rust alternatives install
~/.cargo/bin/cargo install alacritty bottom lsd rm-improved fd-find bat zoxide alacritty cargo-update tree-sitter-cli
~/.cargo/bin/cargo install ripgrep --features pcre2
~/.cargo/bin/cargo install --locked --force xplr

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim source code clone/build
git clone https://github.com/neovim/neovim.git ~/Dev/neovim
cd ~/Dev/neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# Lazyvim setup
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm ~/.config/nvim/.git

# Emacs source code clone/build
git clone https://git.savannah.gnu.org/git/emacs.git ~/Dev/emacs
cd ~/Dev/emacs
git checkout emacs-29
git pull
./autogen.sh
./configure --with-cairo --with-modules --without-compress-install --with-gnutls --with-mailutils --with-native-compilation \
	--with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft \
	--with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local
make -j$(nproc)
sudo make install

# Doom Emacs setup
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Remove firefox snap, as that it how comes by default
snap remove firefox
# Create a directory to store APT repository keys if it doesn't exist:
sudo install -d -m 0755 /etc/apt/keyrings
# Import the Mozilla APT repository signing key:
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
# The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'
# Next, add the Mozilla APT repository to your sources list:
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null

# Update your package list and install the Firefox Nightly .deb package:
sudo apt-get update && sudo apt-get install firefox-devedition

# Clean up Thunar
/usr/bin/rm -rfv ~/.cache/thumbnails

# Make executable update scripts
cat ~/.dotfiles/.local/share/scripts/neovim_update.sh >~/.local/bin/neovimup
cat ~/.dotfiles/.local/share/scripts/emacs_update.sh >~/.local/bin/emacsup
chmod +x ~/.local/bin/neovimup
chmod +x ~/.local/bin/emacsup

# Install mangal
curl -sSL mangal.metafates.one/install | sh

# Oh-my-zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k setup
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
