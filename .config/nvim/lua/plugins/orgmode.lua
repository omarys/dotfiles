return {
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", lazy = true },
    },
    event = "VeryLazy",
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/Dev/Org/Agenda/*",
        org_default_notes_file = "~/Dev/Org/refile.org",
      })
    end,
  },
}
