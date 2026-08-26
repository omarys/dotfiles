-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Org-mode style smart newline (<C-CR> / <C-Enter> / <M-CR>) in Markdown:
-- Repeats headings (#, ##, ***), checkboxes (- [ ]), bullet lists (-, *),
-- numbered lists (incrementing 1. -> 2.), and blockquotes (>).
local function smart_markdown_newline()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]

  local prefix = ""

  -- 1. Checkboxes: "- [ ]", "- [x]", "* [ ]", "+ [ ]"
  local indent, bullet, box = line:match("^([ \t]*)([%-%*%+])%s+%[([ x~>!%-])%]%s*")
  if indent and bullet and box then
    prefix = indent .. bullet .. " [ ] "
  else
    -- 2. Numbered list: "1. ", "2. " (auto-increments number)
    local num_indent, num, dot = line:match("^([ \t]*)(%d+)(%.)%s*")
    if num_indent and num and dot then
      prefix = num_indent .. tostring(tonumber(num) + 1) .. dot .. " "
    else
      -- 3. Bullet list: "- ", "* ", "+ "
      local b_indent, b_char = line:match("^([ \t]*)([%-%*%+])%s*")
      if b_indent and b_char then
        prefix = b_indent .. b_char .. " "
      else
        -- 4. Markdown Headings: "# ", "## ", "### ", etc.
        local heading = line:match("^(#+)%s*")
        if heading then
          prefix = heading .. " "
        else
          -- 5. Org-style Headings: "* ", "** ", "*** ", etc.
          local org_heading = line:match("^(%*+)%s*")
          if org_heading then
            prefix = org_heading .. " "
          else
            -- 6. Blockquotes: "> "
            local quote = line:match("^([ \t]*>+)%s*")
            if quote then
              prefix = quote .. " "
            end
          end
        end
      end
    end
  end

  -- Insert new line below current line with the calculated prefix
  vim.api.nvim_buf_set_lines(0, row, row, false, { prefix })
  -- Position cursor after the prefix on the new line
  vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
  -- Ensure insert mode is active at the new position
  vim.cmd("startinsert!")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_smart_return", { clear = true }),
  pattern = { "markdown", "markdown.mdx", "pandoc" },
  callback = function(event)
    local opts = { buffer = event.buf, silent = true, desc = "Smart Org-style Newline" }
    -- Map <C-CR>, <C-Enter>, <M-CR>, <M-Enter>, and <C-Return> for both Insert and Normal modes
    local keys = { "<C-CR>", "<C-Enter>", "<C-Return>", "<M-CR>", "<M-Enter>" }
    for _, key in ipairs(keys) do
      vim.keymap.set("i", key, smart_markdown_newline, opts)
      vim.keymap.set("n", key, smart_markdown_newline, opts)
    end
  end,
})
