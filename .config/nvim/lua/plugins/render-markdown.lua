return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    ignore = function(buf)
      local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
      if path == "" then
        return false
      end
      return path:find("/Documents/Vaults", 1, true) ~= nil
    end,
  },
}
