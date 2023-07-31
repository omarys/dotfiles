cd ~/Dev/emacs
git checkout emacs-28
# export CC=/usr/bin/gcc-12 CXX=/usr/bin/gcc-12
./autogen.sh
./configure --with-cairo --with-modules --without-compress-install --with-gnutls --with-mailutils --with-native-compilation --with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft --with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local
make -j$(nproc)
