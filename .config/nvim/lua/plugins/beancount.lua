-- Point the beancount language server at the root ledger so diagnostics
-- resolve the full include chain instead of linting files standalone.
-- Requires a Neovim restart after saving.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        beancount = {
          init_options = {
            journal_file = "/home/omary/Dev/hillobeans/main.beancount",
          },
        },
      },
    },
  },
}
