return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- Explicitly override <Tab> without ai_accept to prevent Copilot autocomplete on Tab
      ["<Tab>"] = {
        LazyVim.cmp.map({ "snippet_forward" }),
        "fallback",
      },
      -- Accept Copilot / AI suggestion with <C-l>
      ["<C-l>"] = {
        LazyVim.cmp.map({ "ai_accept" }),
        "fallback",
      },
      -- Dismiss autocomplete popup with <C-x>
      ["<C-x>"] = {
        "cancel",
        "fallback",
      },
    },
  },
}

