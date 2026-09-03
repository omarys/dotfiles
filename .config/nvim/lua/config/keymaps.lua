-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Leader>fs", ":w<CR>", { remap = true, desc = "Save" })
vim.keymap.set("n", "<Leader>ww", ":Neotree toggle<CR>", { remap = true, desc = "Toggle Neotree" })
-- GitHub Copilot Keybindings (supporting both LazyVim native Copilot and copilot.vim)
vim.keymap.set("i", "<C-space>", function()
  if LazyVim.cmp and LazyVim.cmp.actions and LazyVim.cmp.actions.ai_accept then
    if LazyVim.cmp.actions.ai_accept() then
      return
    end
  end
  if vim.lsp and vim.lsp.inline_completion and vim.lsp.inline_completion.get then
    if vim.lsp.inline_completion.get() then
      return
    end
  end
  if vim.fn.exists("*copilot#Accept") == 1 then
    vim.fn.feedkeys(vim.fn["copilot#Accept"](""), "n")
  end
end, { silent = true, desc = "Accept Copilot suggestion" })

vim.keymap.set("i", "<C-j>", function()
  if vim.lsp and vim.lsp.inline_completion and vim.lsp.inline_completion.select then
    vim.lsp.inline_completion.select({ count = 1 })
  elseif vim.fn.exists("*copilot#Next") == 1 then
    vim.fn.feedkeys(vim.fn["copilot#Next"](), "n")
  end
end, { silent = true, desc = "Next Copilot suggestion" })

vim.keymap.set("i", "<C-k>", function()
  if vim.lsp and vim.lsp.inline_completion and vim.lsp.inline_completion.select then
    vim.lsp.inline_completion.select({ count = -1 })
  elseif vim.fn.exists("*copilot#Previous") == 1 then
    vim.fn.feedkeys(vim.fn["copilot#Previous"](), "n")
  end
end, { silent = true, desc = "Previous Copilot suggestion" })

vim.keymap.set("i", "<C-x>", function()
  -- Dismiss blink.cmp autocomplete menu if visible
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.is_visible and blink.is_visible() then
    blink.cancel()
  end
  -- Dismiss Copilot suggestion
  if vim.lsp and vim.lsp.inline_completion then
    vim.lsp.inline_completion.enable(false)
    vim.schedule(function()
      vim.lsp.inline_completion.enable(true)
    end)
  elseif vim.fn.exists("*copilot#Dismiss") == 1 then
    vim.fn.feedkeys(vim.fn["copilot#Dismiss"](), "n")
  end
end, { silent = true, desc = "Dismiss autocomplete & Copilot suggestion" })

vim.keymap.set("i", "<C-;>", function()
  if vim.lsp and vim.lsp.inline_completion then
    vim.lsp.inline_completion.enable()
  elseif vim.fn.exists("*copilot#Suggest") == 1 then
    vim.fn.feedkeys(vim.fn["copilot#Suggest"](), "n")
  end
end, { silent = true, desc = "Suggest Copilot completion" })
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
