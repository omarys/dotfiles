return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      trigger = {
        show_on_x_blocked_trigger_characters = function()
          return vim.bo.filetype == "markdown" and { "'", '"', "(", "{" } or { "'", '"', "(", "{", "[" }
        end,
      },
    },
    keymap = {
      -- Explicitly override <Tab> without ai_accept to prevent Copilot autocomplete on Tab
      ["<Tab>"] = {
        LazyVim.cmp.map({ "snippet_forward" }),
        "fallback",
      },
      -- Accept Copilot / AI suggestion with <C-space>
      ["<C-space>"] = {
        LazyVim.cmp.map({ "ai_accept" }),
        "show",
        "show_documentation",
        "hide_documentation",
        "fallback",
      },
      -- Dismiss autocomplete popup with <C-x>
      ["<C-x>"] = {
        "cancel",
        "fallback",
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        markdown = { inherit_defaults = true, "obsidian" },
      },
      providers = {
        obsidian = {
          name = "obsidian",
          module = "obsidian_blink",
          score_offset = 100,
          async = true,
          timeout_ms = 1000,
        },
      },
    },
  },
}
