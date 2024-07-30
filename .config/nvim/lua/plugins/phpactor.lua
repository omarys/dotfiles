return {
  {
    "gbprod/phpactor.nvim",
    build = function()
      require("phpactor.handler.update")()
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      install = {
        path = "~/.local/bin/",
        bin = "~/.local/bin/phpactor",
        php_bin = "/usr/bin/php",
        composer_bin = "/usr/bin/composer",
        git_bin = "/usr/bin/git",
      },
      lspconfig = {
        enabled = true,
      },
    },
  },
}
