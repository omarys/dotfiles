-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Leader>fs", ":w<CR>", { remap = true, desc = "Save" })
vim.keymap.set("n", "<Leader>ww", ":Neotree toggle<CR>", { remap = true, desc = "Toggle Neotree" })
-- vim.keymap.set("n", "<Leader>y", '"+y', { remap = true, desc = "Yank" })
