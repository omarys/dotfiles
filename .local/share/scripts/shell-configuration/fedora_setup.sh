# RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
# Terra
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
# Upgrade core group and system
sudo dnf group upgrade core
sudo dnf4 group install core
sudo dnf -y update
# Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-devices # Lists devices with available updates.
sudo fwupdmgr get-updates # Fetches list of available updates.
sudo fwupdmgr update
# Add Mullvad repo
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
# Install multimedia packages
sudo dnf4 group install multimedia
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing                                                   # Switch to full FFMPEG.
sudo dnf upgrade @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video                                                             # Installs useful Sound and Video complementary packages.
sudo dnf install ffmpeg-libs libva libva-utils
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
# Configure Firefox OpenH264
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js
# Install Firefox GNOME theme
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
# Speed up boot time
sudo systemctl disable NetworkManager-wait-online.service
sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
# Install Auto Suggestions & Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# Install dev packages (mostly dependencies for emacs)
sudo dnf builddep emacs
sudo dnf install -y zsh git openssl openssl-devel mpv \
  opensc pcsc-perl pcsc-lite pcsc-lite-devel pcsc-tools gcc gcc-c++ make cmake pkgconf-pkg-config \
  freetype-devel fontconfig-devel libxcb xcb-util libxcb-devel python3 tmux aspell aspell-en \
  ninja-build gettext unzip curl stow git autoconf texinfo ImageMagick-devel ImageMagick \
  libgccjit-devel libcgif-devel jansson jansson-devel gnutls libtree-sitter-devel ncurses-devel \
  harfbuzz-devel libacl-devel sbcl sqlite3 steam-devices mpv feh libtool xdotool graphviz gnuplot \
  editorconfig java-latest-openjdk-devel java-latest-openjdk glslang-devel glslang direnv shfmt \
  shellcheck tidy gnutls-devel texlive-scheme-basic texlive-capt-of texlive-ulem texlive-wrapfig \
  texlive-pdfextra mullvad-vpn syncthing automake kernel-devel pamixer wl-clipboard direnv \
  sbcl shfmt shellcheck clang-tools-extra qbittorrent maven php composer keepassxc python3-neovim

# Add flatpak repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Flatpaks install
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install com.mattermost.Desktop info.febvre.Komikku org.gnome.Aisleriot \
  org.gnome.Mahjongg org.gnome.Podcasts org.gnome.Solanum us.zoom.Zoom

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rust packages install
[ -f /home/omary/.cargo/env ] && source /home/omary/.cargo/env
cargo install ripgrep --features pcre2
cargo install --force yazi-build
cargo install bat bottom cargo-update dysk editorconfig fd-find fnm git-delta hoard-rs \
  lsd mani mcfly navi rm-improved starship tealdeer tree-sitter-cli zoxide

# CaC service daemon
sudo systemctl enable --now pcscd

# Tmux package manager install
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Neovim source code clone/build
git clone https://github.com/neovim/neovim.git ~/Dev/neovim
cd ~/Dev/neovim || exit
make CMAKE_BUILD_TYPE=Release && sudo make install

# NPM editor dependencies
sudo npm install -g neovim marked js-beautify stylelint prettier

# Lazyvim setup
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm ~/.config/nvim/.git

# Emacs source code clone/build
git clone git@github.com:emacs-mirror/emacs.git ~/Dev/emacs
cd ~/Dev/emacs || exit
git checkout emacs-30
git pull
./autogen.sh
./configure --with-cairo --with-modules --without-compress-install --with-gnutls --with-mailutils --with-native-compilation --with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft --with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local
make -j"$(nproc)" && sudo make install

# Doom Emacs setup
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Install mangal
curl -sSL mangal.metafates.one/install | sh

# Fonts!
cd ~/Downloads || exit
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Noto.zip
mkdir -p ~/.local/share/fonts
unzip CascadiaCode.zip -d ~/.local/share/fonts/
unzip Noto.zip -d ~/.local/share/fonts/

# Certificates
cd ~/Downloads || exit
curl -LO https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip
unzip unclass-certificates_pkcs7_DoD.zip
openssl pkcs7 -in ~/Downloads/certificates_pkcs7_v5_13_dod/certificates_pkcs7_v5_13_dod_der.p7b \
  -inform der -print_certs -out ~/Downloads/certificates_pkcs7_v5_13_dod/dod_CAs.pem
sudo trust anchor --store certificates_pkcs7_v5_13_dod/dod_CAs.pem

sudo dnf remove docker docker-client docker-client-latest docker-common docker-latest \
  docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo systemctl enable containerd
sudo groupadd docker
sudo usermod -aG docker omary
