cd ~/Dev/neovim
git pull
make CMAKE_BUILD_TYPE=Release

if [[ -x cpack ]]; then
	cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
else
	sudo make install
fi
