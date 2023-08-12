cd ~/Dev/neovim
git pull
make CMAKE_BUILD_TYPE=Release
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
