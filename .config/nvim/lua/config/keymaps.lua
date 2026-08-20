-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Leader>fs", ":w<CR>", { remap = true, desc = "Save" })
vim.keymap.set("n", "<Leader>ww", ":Neotree toggle<CR>", { remap = true, desc = "Toggle Neotree" })
vim.keymap.set(
  "i",
  "<C-l>",
  'copilot#Accept("<CR>")',
  { silent = true, expr = true, desc = "Accept Copilot suggestion" }
)
vim.keymap.set("i", "<C-j>", "copilot#Next()", { silent = true, expr = true, desc = "Next Copilot suggestion" })
vim.keymap.set("i", "<C-k>", "copilot#Previous()", { silent = true, expr = true, desc = "Previous Copilot suggestion" })
vim.keymap.set("i", "<C-x>", "copilot#Dismiss()", { silent = true, expr = true, desc = "Dismiss Copilot suggestion" })
vim.keymap.set(
  "i",
  "<C-space>",
  "copilot#Complete()",
  { silent = true, expr = true, desc = "Complete Copilot suggestion" }
)
vim.keymap.set("i", "<C-;>", "<Plug>(copilot-suggest)")
vim.keymap.set("i", "<M-l>", function()
  return vim.fn["copilot#AcceptWord"]()
end, { expr = true })
vim.keymap.set("i", "<M-S-l>", function()
  return vim.fn["copilot#AcceptLine"]()
end, { expr = true })
-- vim.keymap.set("n", "<Leader>y", '"+y', { remap = true, desc = "Yank" })
