-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Leader>fs", ":w<CR>", { remap = true, desc = "Save" })
vim.keymap.set("n", "<F12>f", ":silent !firefox %<CR>", { remap = true, desc = "Open in Firefox" })
vim.keymap.set("n", "<F12>u", ":UndotreeToggle<CR>", { remap = true, desc = "Toggle UndoTree" })
-- vim.keymap.set("n", "<Leader>y", '"+y', { remap = true, desc = "Yank" })
