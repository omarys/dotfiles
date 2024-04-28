version = "0.21.1"

-- Prompt
xplr.config.general.prompt.format = "❯ "

-- Plugin setup
local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path .. ";" .. xpm_path .. "/?.lua;" .. xpm_path .. "/?/init.lua"

os.execute(string.format("[ -e '%s'  ] || git clone '%s' '%s'", xpm_path, xpm_url, xpm_path))

require("xpm").setup({
	"dtomvan/xpm.xplr",
	"sayanarijit/fzf.xplr",
	"Junker/nuke.xplr",
	"prncss-xyz/icons.xplr",
	"sayanarijit/wl-clipboard.xplr",
	"sayanarijit/alacritty.xplr",
	"sayanarijit/nvim-ctrl.xplr",
	"sayanarijit/tree-view.xplr",
	"sayanarijit/zoxide.xplr",
	"dtomvan/ouch.xplr",
	auto_install = true,
	auto_cleanup = true,
})

-- Neovim integration
require("nvim-ctrl").setup()
-- Open files
require("nuke").setup({
	open = {
		custom = {
			{ mime_regex = "^image/*", command = "feh {}" },
			{ mime_regex = "^video/*", command = "mpv {}" },
			{ mime_regex = ".*", command = "xdg-open {}" },
		},
	},
})
local key = xplr.config.modes.builtin.default.key_bindings.on_key

key.v = {
	help = "nuke",
	messages = { "PopMode", { SwitchModeCustom = "nuke" } },
}
key["f3"] = xplr.config.modes.custom.nuke.key_bindings.on_key.v
key["enter"] = xplr.config.modes.custom.nuke.key_bindings.on_key.o
key["U"] = xplr.config.modes.custom.xpm.key_bindings.on_key.u

xplr.config.general.global_key_bindings = {
	on_key = {
		["m"] = {
			help = "Play all videos with MPV",
			messages = {
				{
					BashExec = [===[
              mpv .
            ]===],
				},
			},
		},
		["esc"] = {
			messages = {
				"PopMode",
			},
		},
		["ctrl-c"] = {
			messages = {
				"Terminate",
			},
		},
	},
}
