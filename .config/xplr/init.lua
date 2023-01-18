<<<<<<< HEAD
version = "0.20.1"
=======
version = "0.20.0"
>>>>>>> 486f0983308d5c6b727ec82e69d3f95b9842f4e4

-- Prompt
xplr.config.general.prompt.format = "❯ "

-- Neovim integration
local home = os.getenv("HOME")
package.path = home
    .. "/.config/xplr/plugins/?/init.lua;"
    .. home
    .. "/.config/xplr/plugins/?.lua;"
    .. package.path
require("nvim-ctrl").setup()

-- Icons
-- local home = os.getenv("HOME")
package.path = os.getenv("HOME") .. '/.config/xplr/plugins/?/src/init.lua'
require "icons".setup()
