sudo apt update && sudo apt install nala -y

# Package update
sudo apt update && sudo nala upgrade -y

# Apt install dependencies
sudo nala install build-essential opensc libpcsc-perl libpcsclite-dev libpcsclite1 libdbus-1-dev \
	pcsc-tools cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
	python3 tmux aspell aspell-en xclip ninja-build gettext cmake unzip curl libssl-dev stow git zsh \
	autoconf texinfo libx11-dev libmagickwand-dev libxaw7-dev libgccjit-12-dev libgif-dev libjansson4 \
	libjansson-dev gnutls-bin libtree-sitter-dev libncurses-dev libtinfo-dev libharfbuzz-dev libacl1-dev \
	libxinerama-dev libxcb-xinerama0-dev sbcl sqlite3 steam-devices mpv feh python3-pip libtool-bin libtool \
	xdotool graphviz gnuplot editorconfig npm nodejs default-jdk glslang-dev glslang-tools clang-format \
	direnv shfmt shellcheck tidy gnutls-dev texlive-latex-base texlive-fonts-recommended texlive-fonts-extra \
	texlive-latex-extra plasma-discover-backend-flatpak

# Flatpaks install
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install org.keepassxc.KeePassXC com.discordapp.Discord com.valvesoftware.Steam \
	com.valvesoftware.Steam.Utility.MangoHud com.valvesoftware.Steam.Utility.steamtinkerlaunch \
	org.freedesktop.Platform.VulkanLayer.gamescope

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#
# Install alacritty
cd ~/Downloads
git clone https://github.com/alacritty/alacritty.git
cd alacritty
cargo build --release --no-default-features --features=wayland
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# Rust alternatives install
~/.cargo/bin/cargo install alacritty bottom lsd rm-improved fd-find bat zoxide cargo-update tree-sitter-cli
sudo ln -s ~/.cargo/bin/alacritty /usr/local/bin/alacritty
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

# Editor dependencies install
pip install --user neovim lazygit wheel ansible black grip pyflakes \
	isort pipenv nose pytest pipx --break-system-packages
sudo npm install -g neovim marked js-beautify stylelint

# Lazyvim setup
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm ~/.config/nvim/.git

# Emacs source code clone/build
git clone https://git.savannah.gnu.org/git/emacs.git ~/Dev/emacs
cd ~/Dev/emacs
git checkout emacs-29
git pull
./autogen.sh
./configure --with-cairo --with-modules --without-compress-install --with-gnutls --with-mailutils --with-native-compilation --with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft --with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local
make -j$(nproc)
sudo make install

# Doom Emacs setup
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Python-poetry install/setup
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh >$ZSH_CUSTOM/plugins/poetry/_poetry

# Clean up Thunar
/usr/bin/rm -rfv ~/.cache/thumbnails

# Oh-my-zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && exit

# Powerlevel10k setup
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Prepare for stow
cd ~/.dotfiles
rm -r ~/.*shrc
rm -r ~/.config/doom/*.el
stow .
