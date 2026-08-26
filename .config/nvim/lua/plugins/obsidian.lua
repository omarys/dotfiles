local function create_zettel_from_file(is_visual)
  local origin_buf = vim.api.nvim_get_current_buf()
  local origin_path = vim.api.nvim_buf_get_name(origin_buf)
  if origin_path == "" then
    vim.notify("Origin file must be saved before creating a linked note", vim.log.levels.WARN)
    return
  end

  local origin_stem = vim.fn.fnamemodify(origin_path, ":t:r")
  local origin_rel = vim.fn.fnamemodify(origin_path, ":~:.")

  local selected_lines = {}
  local start_row, end_row = 0, 0

  if is_visual then
    local v_start = vim.fn.getpos("'<")
    local v_end = vim.fn.getpos("'>")
    start_row = v_start[2] - 1
    end_row = v_end[2]
    selected_lines = vim.api.nvim_buf_get_lines(origin_buf, start_row, end_row, false)
  else
    local cursor = vim.api.nvim_win_get_cursor(0)
    start_row = cursor[1] - 1
    end_row = cursor[1]
  end

  vim.ui.input({ prompt = "Zettel Title: " }, function(title)
    if not title or title:match("^%s*$") then
      return
    end

    -- Determine active vault directory
    local vault_dir = vim.fn.expand("~/vaults/research")
    local ok_obsidian, obsidian = pcall(require, "obsidian")
    if ok_obsidian then
      local client = obsidian.get_client()
      if client and client.current_workspace then
        vault_dir = tostring(client.current_workspace.path)
      end
    end

    local notes_dir = vault_dir .. "/notes"
    vim.fn.mkdir(notes_dir, "p")

    local slug = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    local note_id = os.date("%Y%m%d%H%M") .. "-" .. slug
    local new_file_path = notes_dir .. "/" .. note_id .. ".md"

    -- Determine backlink format
    local is_in_vault = origin_path:find(vim.fn.expand("~/vaults"), 1, true) ~= nil
    local backlink = ""
    if is_in_vault then
      backlink = string.format("- Origin Note: [[%s]]", origin_stem)
    else
      backlink = string.format("- Origin File: [%s](%s)", origin_rel, origin_path)
    end

    local timestamp = os.date("%Y-%m-%d %H:%M")
    local new_content = {
      "---",
      "id: " .. note_id,
      'title: "' .. title .. '"',
      "aliases:",
      '  - "' .. title .. '"',
      "tags:",
      "  - type/permanent",
      "created: " .. timestamp,
      "modified: " .. timestamp,
      "---",
      "",
      "## " .. title,
      "",
    }

    if #selected_lines > 0 then
      for _, line in ipairs(selected_lines) do
        table.insert(new_content, line)
      end
      table.insert(new_content, "")
    else
      table.insert(new_content, "> Summary / Core Thesis")
      table.insert(new_content, "")
    end

    table.insert(new_content, "---")
    table.insert(new_content, "## Context & References")
    table.insert(new_content, backlink)
    table.insert(new_content, "")

    -- Write new note file
    local f = io.open(new_file_path, "w")
    if f then
      f:write(table.concat(new_content, "\n"))
      f:close()
    else
      vim.notify("Failed to write note: " .. new_file_path, vim.log.levels.ERROR)
      return
    end

    -- Insert/replace link in origin file
    local link_text = string.format("[[%s|%s]]", note_id, title)
    if is_visual then
      vim.api.nvim_buf_set_lines(origin_buf, start_row, end_row, false, { link_text })
    else
      vim.api.nvim_buf_set_lines(origin_buf, start_row, start_row, false, { "- " .. link_text })
    end

    -- Open the new note in a NEW TAB
    vim.cmd("tabedit " .. vim.fn.fnameescape(new_file_path))
    vim.notify("Created Zettel in new tab: " .. note_id, vim.log.levels.INFO)
  end)
end

local function create_jira_ticket_note()
  vim.ui.input({ prompt = "Jira Key (e.g. PROJ-1234, optional): " }, function(jira_key)
    jira_key = jira_key or ""
    jira_key = vim.trim(jira_key):upper()

    vim.ui.input({ prompt = "Ticket Title: " }, function(title)
      if not title or title:match("^%s*$") then
        return
      end

      local vault_dir = vim.fn.expand("~/vaults/work")
      local ok_obsidian, obsidian = pcall(require, "obsidian")
      if ok_obsidian then
        local client = obsidian.get_client()
        if client and client.current_workspace then
          vault_dir = tostring(client.current_workspace.path)
        end
      end

      local notes_dir = vault_dir .. "/notes"
      vim.fn.mkdir(notes_dir, "p")

      local slug_prefix = jira_key ~= "" and (jira_key:lower() .. "-") or ""
      local slug = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      local note_id = os.date("%Y%m%d%H%M") .. "-" .. slug_prefix .. slug
      local new_file_path = notes_dir .. "/" .. note_id .. ".md"
      local timestamp = os.date("%Y-%m-%d %H:%M")
      local header_title = (jira_key ~= "" and ("[" .. jira_key .. "] ") or "") .. title

      local content = {
        "---",
        "id: " .. note_id,
        'title: "' .. header_title .. '"',
        "aliases:",
        '  - "' .. header_title .. '"',
        jira_key ~= "" and ('  - "' .. jira_key .. '"') or nil,
        "tags:",
        "  - jira",
        "  - ticket",
        "  - status/todo",
        "jira_key: " .. (jira_key ~= "" and ('"' .. jira_key .. '"') or '""'),
        "created: " .. timestamp,
        "modified: " .. timestamp,
        "---",
        "",
        "## [ ] " .. header_title,
        "",
        "- **Jira Key**: " .. (jira_key ~= "" and jira_key or "N/A"),
        "- **Status**: #status/todo",
        "- **Created**: " .. timestamp,
        "- **Jira Link**: ",
        "",
        "---",
        "",
        "### Description",
        "> ",
        "",
        "---",
        "",
        "### Definition of Done (DoD)",
        "- [ ] Acceptance criteria implemented",
        "- [ ] Unit & integration tests passing",
        "- [ ] Code review completed & approved",
        "- [ ] CI/CD green & PR merged",
        "- [ ] Verified in environment",
        "",
        "---",
        "",
        "### Technical Approach & Design",
        "- ",
        "",
        "---",
        "",
        "### Investigation & Work Log",
        "- ",
        "",
        "---",
        "",
        "### PRs, Commits & Related Notes",
        "- Pull Request: ",
        "- Related Zettels: [[]]",
        "",
      }

      local clean_content = {}
      for _, line in ipairs(content) do
        if line ~= nil then
          table.insert(clean_content, line)
        end
      end

      local f = io.open(new_file_path, "w")
      if f then
        f:write(table.concat(clean_content, "\n"))
        f:close()
        vim.cmd("edit " .. vim.fn.fnameescape(new_file_path))
        vim.notify("Created Jira note: " .. note_id, vim.log.levels.INFO)
      else
        vim.notify("Failed to create Jira note: " .. new_file_path, vim.log.levels.ERROR)
      end
    end)
  end)
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  cmd = {
    "ObsidianNew",
    "ObsidianQuickSwitch",
    "ObsidianSearch",
    "ObsidianTemplate",
    "ObsidianToday",
    "ObsidianYesterday",
    "ObsidianTomorrow",
    "ObsidianBacklinks",
    "ObsidianLinks",
    "ObsidianExtractNote",
    "ObsidianRename",
    "ObsidianPasteImg",
    "ObsidianWorkspace",
    "ObsidianToggleCheckbox",
    "ObsidianTags",
    "ObsidianCheck",
  },
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/vaults/**.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>zn", "<cmd>ObsidianNew<cr>", desc = "Zettel: New Note" },
    {
      "<leader>zj",
      function()
        create_jira_ticket_note()
      end,
      desc = "Zettel: New Jira Ticket Note",
    },
    { "<leader>zf", "<cmd>ObsidianQuickSwitch<cr>", desc = "Zettel: Find Note (Quick Switch)" },
    { "<leader>zs", "<cmd>ObsidianSearch<cr>", desc = "Zettel: Search Notes (Grep)" },
    { "<leader>zt", "<cmd>ObsidianTemplate<cr>", desc = "Zettel: Insert Template" },
    { "<leader>zd", "<cmd>ObsidianToday<cr>", desc = "Zettel: Today's Daily Note" },
    { "<leader>zy", "<cmd>ObsidianYesterday<cr>", desc = "Zettel: Yesterday's Daily Note" },
    { "<leader>zm", "<cmd>ObsidianTomorrow<cr>", desc = "Zettel: Tomorrow's Daily Note" },
    { "<leader>zb", "<cmd>ObsidianBacklinks<cr>", desc = "Zettel: Show Backlinks" },
    { "<leader>zl", "<cmd>ObsidianLinks<cr>", desc = "Zettel: Show Forward Links" },
    { "<leader>ze", ":'<,'>ObsidianExtractNote<cr>", mode = "v", desc = "Zettel: Extract Visual Selection to Note" },
    {
      "<leader>zx",
      function()
        create_zettel_from_file(true)
      end,
      mode = "v",
      desc = "Zettel: Extract Selection to New Tab with Backlink",
    },
    {
      "<leader>zx",
      function()
        create_zettel_from_file(false)
      end,
      mode = "n",
      desc = "Zettel: Create Note from Current File in New Tab with Backlink",
    },
    { "<leader>zr", "<cmd>ObsidianRename<cr>", desc = "Zettel: Rename Note (Update Links)" },
    { "<leader>zp", "<cmd>ObsidianPasteImg<cr>", desc = "Zettel: Paste Image from Clipboard" },
    { "<leader>zw", "<cmd>ObsidianWorkspace<cr>", desc = "Zettel: Switch Workspace" },
    { "<leader>zc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Zettel: Toggle Checkbox" },
  },
  opts = {
    -- Workspaces: Structured for Educational & Professional Research
    workspaces = {
      {
        name = "research",
        path = "~/vaults/research",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
      {
        name = "personal",
        path = "~/vaults/personal",
      },
    },

    -- Default subdirectory for new zettels
    notes_subdir = "notes",

    -- Daily journal & log settings
    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = "daily.md",
    },

    -- Wiki-link vs Markdown link style
    preferred_link_style = "wiki",

    -- Completion engine integration (nvim-cmp / blink.cmp)
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    -- Zettelkasten Note ID Generation:
    -- Formats as YYYYMMDDHHMM or YYYYMMDDHHMM-kebab-case-title
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        -- Transform title into clean kebab-case
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- 4 random letters if no title given
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.date("%Y%m%d%H%M")) .. "-" .. suffix
    end,

    -- Frontmatter generator for structured Zettelkasten metadata
    note_frontmatter_func = function(note)
      -- Add title as alias if available
      if note.title then
        note:add_alias(note.title)
      end

      local out = {
        id = note.id,
        title = note.title or "",
        aliases = note.aliases,
        tags = note.tags,
        created = os.date("%Y-%m-%d %H:%M"),
        modified = os.date("%Y-%m-%d %H:%M"),
      }

      -- Retain any existing custom frontmatter fields
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          if out[k] == nil then
            out[k] = v
          end
        end
      end

      return out
    end,

    -- Templates directory and placeholder substitutions
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        author = function()
          return "Omar"
        end,
      },
    },

    -- Attachment & Image configuration
    attachments = {
      img_folder = "assets/images",
      img_name_func = function()
        return string.format("img-%s", os.date("%Y%m%d%H%M%S"))
      end,
    },

    -- Smart UI enhancements (conceal markdown formatting, render checkboxes & tags)
    ui = {
      enable = true,
      update_debounce = 200,
      max_file_length = 5000,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        ["!"] = { char = "", hl_group = "ObsidianImportant" },
      },
      bullets = { char = "•", hl_group = "ObsidianBullet" },
      external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      reference_text = { hl_group = "ObsidianRefText" },
      highlight_text = { hl_group = "ObsidianHighlightText" },
      tags = { hl_group = "ObsidianTag" },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = "#f7768e" },
        ObsidianDone = { bold = true, fg = "#73daca" },
        ObsidianRightArrow = { bold = true, fg = "#7aa2f7" },
        ObsidianTilde = { bold = true, fg = "#bb9af7" },
        ObsidianImportant = { bold = true, fg = "#e0af68" },
        ObsidianBullet = { bold = true, fg = "#89ddff" },
        ObsidianRefText = { underline = true, fg = "#c0caf5" },
        ObsidianExtLinkIcon = { fg = "#7aa2f7" },
        ObsidianTag = { italic = true, fg = "#bb9af7" },
        ObsidianHighlightText = { bg = "#756b2c" },
      },
    },

    -- Backlink & link display options
    backlinks = {
      height = 10,
      wrap = true,
    },
  },
}
