version = "0.19.0"

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
