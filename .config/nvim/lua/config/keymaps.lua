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
-- vim.keymap.set("n", "<Leader>y", '"+y', { remap = true, desc = "Yank" })

-- Preview the current file in a vertical Neovim termainal split using Leaf
vim.keymap.set("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  if file ~= "" then
    vim.cmd("vsplit | term leaf -w " .. vim.fn.shellescape(file))
  else
    print("No file to preview")
  end
end, { desc = "Preview current file in Leaf" })

-- Toggle Checkbox in Markdown files
vim.keymap.set("n", "<leader>tc", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("%[ %]") then
    line = line:gsub("%[ %]", "[✓]")
  elseif line:match("%[x%]") then
    line = line:gsub("%[x%]", "[ ]")
  end
  vim.api.nvim_set_current_line(line)
end, { desc = "Toggle Checkbox in Markdown" })
