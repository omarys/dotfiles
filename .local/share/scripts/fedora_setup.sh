# RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add Mullvad repo
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf copr enable erikreider/SwayNotificationCenter

# Update packages
sudo dnf -y update
sudo dnf -y upgrade --refresh

# Install multimedia packages
sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setop='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

# Install dev packages (mostly dependencies for emacs)
sudo dnf group install "Development Tools"
sudo dnf builddep emacs
sudo dnf install -y zsh git openssl openssl-devel alacritty mpv ffmpeg ffmpeg-libs libva libva-utils \
	opensc pcsc-perl pcsc-lite pcsc-lite-devel pcsc-tools gcc gcc-c++ make cmake pkgconf-pkg-config \
	freetype-devel fontconfig-devel libxcb xcb-util libxcb-devel python3 tmux aspell aspell-en xclip \
	ninja-build gettext unzip curl stow git zsh autoconf texinfo ImageMagick-devel ImageMagick \
	libgccjit-devel libcgif-devel jansson jansson-devel gnutls libtree-sitter-devel ncurses-devel \
	harfbuzz-devel libacl-devel sbcl sqlite3 steam-devices mpv feh libtool xdotool graphviz gnuplot \
	editorconfig npm nodejs java-latest-openjdk-devel java-latest-openjdk glslang-devel glslang direnv \
	shfmt shellcheck tidy gnutls-devel texlive-scheme-basic texlive-capt-of texlive-ulem texlive-wrapfig \
	texlive-pdfextra fuzzel greetd tlp tlp-rdw powertop mullvad-vpn SwayNotificationCenter syncthing \
	wob pamixer brightnessctl flatpak

# Configure powertop
sudo systemctl mask power-profiles-daemon
sudo powertop --auto-tune

# OpenH264 for Firefox
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264

# Flatpaks install
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install com.discordapp.Discord com.valvesoftware.Steam \
	com.valvesoftware.Steam.Utility.MangoHud com.valvesoftware.Steam.Utility.steamtinkerlaunch \
	org.freedesktop.Platform.VulkanLayer.gamescope org.keepassxc.KeePassXC

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rust packages install
~/.cargo/bin/cargo install bottom lsd rm-improved fd-find bat \
	zoxide cargo-update tree-sitter-cli editorconfig starship
~/.cargo/bin/cargo install ripgrep --features pcre2
~/.cargo/bin/cargo install --locked --force xplr

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim source code clone/build
git clone https://github.com/neovim/neovim.git ~/Dev/neovim
cd ~/Dev/neovim
make && sudo make install

# Editor dependencies from pip and node
python -m ensurepip --user
pip3 install --upgrade pip --user
pip install --user pipx neovim
pipx install lazygit wheel ansible black grip pyflakes isort pipenv nose pytest yt-dlp
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
make -j$(nproc) && sudo make install

# Doom Emacs setup
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Install mangal
curl -sSL mangal.metafates.one/install | sh

# Fonts!
cd ~/Downloads
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Noto.zip
mkdir -p ~/.local/share/fonts
unzip CascadiaCode.zip -d ~/.local/share/fonts/
unzip Noto.zip -d ~/.local/share/fonts/

# Certificates
cd ~/Downloads
curl -LO https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip
unzip unclass-certificates_pkcs7_DoD.zip
openssl pkcs7 -in ~/Downloads/certificates_pkcs7_v5_13_dod/certificates_pkcs7_v5_13_dod_der.p7b \
	-inform der -print_certs -out ~/Downloads/certificates_pkcs7_v5_13_dod/dod_CAs.pem
sudo trust anchor --store certificates_pkcs7_v5_13_dod/dod_CAs.pem

# Wttr bar for weather
mkdir -p ~/Dev && cd ~/Dev
git clone https://github.com/bjesus/wttrbar.git
cd wttrbar
cargo build --release
cp target/release/wttrbar ~/.cargo/bin/

# Oh-my-bash setup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Clean up cache (previously for Thunar)
/usr/bin/rm -rfv ~/.cache/thumbnails
