--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

local cache = {}

local function get_workspace_name(client)
  if client and client.current_workspace and client.current_workspace.name then
    return client.current_workspace.name
  end
  return "default"
end

local function warm_cache(client, callback)
  if not client then
    if callback then
      callback(nil)
    end
    return
  end
  local ws_name = get_workspace_name(client)
  client:find_notes_async("", function(notes)
    cache[ws_name] = {
      notes = notes,
      timestamp = vim.uv.now(),
    }
    if callback then
      vim.schedule(function()
        callback(notes)
      end)
    end
  end, { search = { ignore_case = true } })
end

-- Pre-warm cache on markdown buffer open and refresh on save
local augroup = vim.api.nvim_create_augroup("ObsidianBlinkCache", { clear = true })
-- mini.pairs moves the cursor after inserting closing brackets, hiding Blink's menu.
vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
  group = augroup,
  pattern = "*.md",
  callback = function()
    vim.schedule(function()
      if vim.fn.mode() ~= "i" or not source:enabled() then
        return
      end
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before = vim.api.nvim_get_current_line():sub(1, col)
      local cmp = require("blink.cmp")
      if before:match("%[%[$") and not cmp.is_visible() then
        cmp.show({ providers = { "obsidian" } })
      end
    end)
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = augroup,
  pattern = "*.md",
  callback = function()
    vim.schedule(function()
      local ok, obsidian = pcall(require, "obsidian")
      if ok then
        local client = obsidian.get_client()
        if client then
          local ws_name = get_workspace_name(client)
          if not cache[ws_name] or (vim.uv.now() - cache[ws_name].timestamp > 300000) then
            warm_cache(client)
          end
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*.md",
  callback = function()
    vim.schedule(function()
      local ok, obsidian = pcall(require, "obsidian")
      if ok then
        local client = obsidian.get_client()
        if client then
          warm_cache(client)
        end
      end
    end)
  end,
})

function source.new(opts)
  local ok, obsidian = pcall(require, "obsidian")
  if ok then
    local client = obsidian.get_client()
    if client then
      warm_cache(client)
    end
  end
  return setmetatable({ opts = opts or {} }, { __index = source })
end

function source:enabled()
  if vim.bo.filetype ~= "markdown" then
    return false
  end
  local ok, obsidian = pcall(require, "obsidian")
  if not ok then
    return false
  end
  local client = obsidian.get_client()
  return client ~= nil
end

function source:get_trigger_characters()
  return { "[", "#" }
end

function source:get_completions(context, callback)
  local ok, obsidian = pcall(require, "obsidian")
  if not ok then
    return callback({ items = {} })
  end
  local client = obsidian.get_client()
  if not client then
    return callback({ items = {} })
  end

  local cursor_row = context.cursor[1] - 1 -- 0-indexed line number for LSP range
  local cursor_col = context.cursor[2]     -- 0-indexed byte column
  local line = context.line
  local before = line:sub(1, cursor_col)
  local after = line:sub(cursor_col + 1)

  -- Ignore markdown task checkboxes (e.g. "- [ ] " or "* [x] ")
  if before:match("^%s*[%-%*%+]%s*%[[%s%w>!~x%-]*$") then
    return callback({ items = {} })
  end

  -- Scan backwards from cursor to find unclosed '[' or '[['
  local link_type = nil
  local link_start_idx = nil -- 1-indexed in 'line'
  local search_query = nil

  for i = #before, 1, -1 do
    local char = before:sub(i, i)
    if char == "]" then
      -- Closed bracket encountered before open bracket; cursor is outside link
      break
    elseif char == "[" then
      if i > 1 and before:sub(i - 1, i - 1) == "[" then
        link_type = "wiki"
        link_start_idx = i - 1
        search_query = before:sub(i + 1)
      else
        link_type = "markdown"
        link_start_idx = i
        search_query = before:sub(i + 1)
      end
      break
    end
  end

  -- For single '[' (markdown link), only complete if user has started typing a query
  if link_type == "markdown" and (not search_query or #search_query == 0) then
    link_type = nil
  end

  -- Tag completion check (if '#' without an unclosed link)
  local tag_prefix = nil
  if not link_type then
    -- Don't match markdown headings ("# Heading" or "## ")
    if not before:match("^%s*#+%s*$") then
      tag_prefix = before:match("#([%w%-_/]*)$")
    end
  end

  if not link_type and not tag_prefix then
    return callback({ items = {} })
  end

  -- Handle tag completion
  if tag_prefix then
    local start_char = cursor_col - #tag_prefix - 1 -- includes the '#'
    local range = {
      start = { line = cursor_row, character = start_char },
      ["end"] = { line = cursor_row, character = cursor_col },
    }
    client:find_tags_async(tag_prefix, function(tag_locs)
      vim.schedule(function()
        local tags = {}
        for _, loc in ipairs(tag_locs or {}) do
          if loc.tag then
            tags[loc.tag] = true
          end
        end
        local items = {}
        for tag, _ in pairs(tags) do
          table.insert(items, {
            label = "#" .. tag,
            kind = require("blink.cmp.types").CompletionItemKind.Keyword,
            filterText = tag,
            sortText = tag,
            textEdit = {
              newText = "#" .. tag,
              range = range,
            },
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
          })
        end
        callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
      end)
    end)
    return function() end
  end

  -- Handle note links (Wiki [[ or Markdown [)
  local start_char = link_start_idx - 1 -- 0-indexed column of opening bracket(s)
  local end_char = cursor_col

  if link_type == "wiki" then
    local closing = after:match("^([^%]]*%]%])")
    if closing then
      end_char = cursor_col + #closing
    end
  elseif link_type == "markdown" then
    local closing = after:match("^([^%]]*%])")
    if closing then
      end_char = cursor_col + #closing
    end
  end

  local range = {
    start = { line = cursor_row, character = start_char },
    ["end"] = { line = cursor_row, character = end_char },
  }

  local clean_search = search_query or ""

  -- Anchor / block links within current buffer, e.g. [[#
  local util = require("obsidian.util")
  local search_without_block, block_link = util.strip_block_links(clean_search)
  local anchor_link
  search_without_block, anchor_link = util.strip_anchor_links(search_without_block)

  if (anchor_link or block_link) and #search_without_block == 0 then
    local current_note = client:current_note(0, { collect_anchor_links = true, collect_blocks = true })
    local items = {}
    if current_note then
      if current_note.anchor_links then
        for _, anchor in pairs(current_note.anchor_links) do
          local new_text = (link_type == "wiki") and ("[[#" .. anchor.header .. "]]")
            or ("[#" .. anchor.header .. "](" .. anchor.anchor .. ")")
          table.insert(items, {
            label = "#" .. anchor.header,
            kind = require("blink.cmp.types").CompletionItemKind.Reference,
            filterText = anchor.header,
            sortText = anchor.header,
            detail = "Header anchor",
            textEdit = {
              newText = new_text,
              range = range,
            },
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
          })
        end
      end
      if current_note.blocks then
        for block_id, _ in pairs(current_note.blocks) do
          local new_text = (link_type == "wiki") and ("[[#" .. block_id .. "]]")
            or ("[#" .. block_id .. "](#" .. block_id .. ")")
          table.insert(items, {
            label = "#^" .. block_id,
            kind = require("blink.cmp.types").CompletionItemKind.Reference,
            filterText = block_id,
            sortText = block_id,
            detail = "Block reference",
            textEdit = {
              newText = new_text,
              range = range,
            },
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
          })
        end
      end
    end
    callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
    return function() end
  end

  local function build_items(notes)
    local items = {}
    local seen = {}

    for _, note in ipairs(notes) do
      local note_id = tostring(note.id)
      local title = note.title or note_id
      local display_name = (note.display_name and note:display_name()) or title

      local ok_link, formatted_link = pcall(function()
        return client:format_link(note, {
          label = display_name,
          link_style = (link_type == "wiki") and "wiki" or "markdown",
        })
      end)

      local new_text = (ok_link and formatted_link) or ("[[" .. display_name .. "]]")
      if link_type == "markdown" and not new_text:match("^%[.*%]%(.*%)$") then
        new_text = "[" .. display_name .. "](" .. note_id .. ".md)"
      end

      if not seen[new_text] then
        seen[new_text] = true
        local filter_parts = { display_name, title, note_id }
        if note.aliases then
          for _, a in ipairs(note.aliases) do
            table.insert(filter_parts, a)
          end
        end

        local doc_lines = { "# " .. display_name, "" }
        if note.id and tostring(note.id) ~= display_name then
          table.insert(doc_lines, "**ID**: `" .. tostring(note.id) .. "`")
        end
        if note.path then
          table.insert(doc_lines, "**Path**: `" .. tostring(note.path) .. "`")
        end
        if note.aliases and #note.aliases > 0 then
          table.insert(doc_lines, "**Aliases**: " .. table.concat(note.aliases, ", "))
        end

        table.insert(items, {
          label = (link_type == "wiki") and ("[[" .. display_name .. "]]") or ("[" .. display_name .. "]"),
          kind = require("blink.cmp.types").CompletionItemKind.Reference,
          filterText = table.concat(filter_parts, " "),
          sortText = display_name,
          detail = (note_id ~= display_name) and note_id or (note.path and vim.fs.basename(tostring(note.path))),
          documentation = {
            kind = "markdown",
            value = table.concat(doc_lines, "\n"),
          },
          textEdit = {
            newText = new_text,
            range = range,
          },
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        })
      end

      -- Also include aliases as completion options
      if note.aliases then
        for _, alias in ipairs(note.aliases) do
          if alias ~= display_name and alias ~= title and alias ~= note_id then
            local alias_link = (link_type == "wiki") and ("[[" .. note_id .. "|" .. alias .. "]]")
              or ("[" .. alias .. "](" .. note_id .. ".md)")
            pcall(function()
              alias_link = client:format_link(note, {
                label = alias,
                link_style = (link_type == "wiki") and "wiki" or "markdown",
              })
            end)

            if not seen[alias_link] then
              seen[alias_link] = true
              table.insert(items, {
                label = (link_type == "wiki") and ("[[" .. alias .. "]]") or ("[" .. alias .. "]"),
                kind = require("blink.cmp.types").CompletionItemKind.Reference,
                filterText = alias .. " " .. display_name .. " " .. title .. " " .. note_id,
                sortText = alias,
                detail = "Alias of " .. display_name,
                documentation = {
                  kind = "markdown",
                  value = "# " .. alias .. "\n\n*Alias of " .. display_name .. "* (`" .. note_id .. "`)",
                },
                textEdit = {
                  newText = alias_link,
                  range = range,
                },
                insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
              })
            end
          end
        end
      end
    end

    -- If user typed a search term, offer to create a new note
    if #clean_search > 0 then
      local create_new_text = (link_type == "wiki")
        and ("[[" .. clean_search .. "]]")
        or ("[" .. clean_search .. "](" .. clean_search .. ".md)")

      table.insert(items, {
        label = (link_type == "wiki") and ("Create: [[" .. clean_search .. "]]")
          or ("Create: [" .. clean_search .. "]"),
        kind = require("blink.cmp.types").CompletionItemKind.Text,
        filterText = clean_search,
        sortText = "~" .. clean_search,
        detail = "New note",
        documentation = {
          kind = "markdown",
          value = "Create new note titled `" .. clean_search .. "`",
        },
        textEdit = {
          newText = create_new_text,
          range = range,
        },
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
      })
    end

    return items
  end

  local ws_name = get_workspace_name(client)
  local cached = cache[ws_name]
  local now = vim.uv.now()

  -- Check if cache is fresh (< 5 minutes)
  if cached and cached.notes and (now - cached.timestamp < 300000) then
    local items = build_items(cached.notes)
    callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
    return function() end
  end

  -- Cache miss or expired: fetch async and return
  warm_cache(client, function(notes)
    local items = build_items(notes or {})
    callback({
      items = items,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
    })
  end)

  return function() end
end

return source
