if [ ! -d ~/.config/xplr/plugin ]; then
  mkdir -p ~/.config/xplr/plugins
  git clone https://github.com/sayanarijit/nvim-ctrl.xplr ~/.config/xplr/plugins/nvim-ctrl
  git clone https://github.com/prncss-xyz/icons.xplr ~/.config/xplr/plugins/icons
  git clone https://github.com/Junker/nuke.xplr ~/.config/xplr/plugins/nuke
fi
