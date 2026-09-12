-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable default <Tab> mapping for GitHub Copilot (must be set before plugin initialization)
vim.g.copilot_no_tab_map = true

-- Folding options: use treesitter expression folding by default
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.LazyVim.treesitter.foldexpr()"
