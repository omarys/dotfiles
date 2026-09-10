return {
  {
    "omarys/altex.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "Altex", "AltexKey" },
    keys = {
      {
        "<leader>sk",
        function()
          require("altex").list()
        end,
        desc = "Commands & mappings",
      },
      {
        "<leader>sK",
        function()
          require("altex").describe()
        end,
        desc = "Describe key sequence",
      },
    },
    opts = {},
  },
}
