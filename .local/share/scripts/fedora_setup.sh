# Oh-my-zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k setup
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Apt install dependencies
sudo dnf group install "Development Tools"
sudo dnf builddep emacs
sudo dnf install opensc pcsc-perl pcsc-lite pcsc-lite-devel pcsc-tools gcc gcc-c++ make cmake openssl-devel pkgconf-pkg-config freetype-devel fontconfig-devel libxcb xcb-util libxcb-devel python3 tmux aspell aspell-en xclip ninja-build gettext unzip curl stow git zsh autoconf texinfo ImageMagick-devel ImageMagick libgccjit-devel libcgif-devel jansson jansson-devel gnutls libtree-sitter-devel ncurses-devel harfbuzz-devel libacl-devel sbcl sqlite3 steam-devices mpv feh libtool xdotool graphviz gnuplot editorconfig npm nodejs java-latest-openjdk-devel java-latest-openjdk glslang-devel glslang direnv shfmt shellcheck tidy gnutls-devel texlive-scheme-basic

# Flatpaks install
flatpak install org.keepassxc.KeePassXC com.discordapp.Discord com.valvesoftware.Steam com.valvesoftware.Steam.Utility.MangoHud com.valvesoftware.Steam.Utility.steamtinkerlaunch org.freedesktop.Platform.VulkanLayer.gamescope org.gnome.Mahjongg org.gnome.Aisleriot

# Rust alternatives install
cargo install bottom lsd rm-improved fd-find bat zoxide alacritty cargo-update tree-sitter-cli
cargo install ripgrep --features pcre2
cargo install --locked --force xplr

# Alacritty requires symbolic link for desktop entry
sudo ln -s /home/USER/.cargo/bin/alacritty /usr/local/bin/alacritty

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim source code clone/build
git clone https://github.com/neovim/neovim.git ~/Dev/neovim
cd ~/Dev/neovim
make && sudo make install

# Editor dependencies install
pip install --user neovim lazygit wheel ansible black grip pyflakes isort pipenv nose pytest

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
curl -sSL https://install.python-poetry.org | python3 -
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh >$ZSH_CUSTOM/plugins/poetry/_poetry

# Clean up Thunar
/usr/bin/rm -rfv ~/.cache/thumbnails
