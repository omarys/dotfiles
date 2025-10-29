cd ~/Dev/neovim || exit
git pull
make CMAKE_BUILD_TYPE=Release

if [[ "$(uname -n)" = "fedora" ]]; then
  sudo make install
else
  cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
fi
