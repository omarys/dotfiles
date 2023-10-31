# Oh-my-zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k setup
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Apt install dependencies
sudo apt install build-essential opensc libpcsc-perl libpcsclite-dev libpcsclite1 libdbus-1-dev pcsc-tools cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 tmux aspell aspell-en xclip ninja-build gettext cmake unzip curl libssl-dev stow git zsh autoconf texinfo libx11-dev libmagickwand-dev libxaw7-dev libgccjit-11-dev libgif-dev libjansson4 libjansson-dev gnutls-bin libtree-sitter-dev libncurses-dev libtinfo-dev libharfbuzz-dev libacl1-dev libxinerama-dev libxcb-xinerama0-dev sbcl sqlite3 steam-devices mpv feh python3-pip libtool-bin libtool xdotool graphviz gnuplot editorconfig npm nodejs openjdk-19-jdk glslang-dev glslang-tools clang-format direnv shfmt shellcheck tidy gnutls-dev texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra

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
make CMAKE_BUILD_TYPE=RelWithDebInfo

# Editor dependencies install
pip install --user neovim lazygit wheel ansible black grip pyflakes isort pipenv nose pytest
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
curl -sSL https://install.python-poetry.org | python3 -
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh >$ZSH_CUSTOM/plugins/poetry/_poetry

# Clean up Thunar
/usr/bin/rm -rfv ~/.cache/thumbnails
