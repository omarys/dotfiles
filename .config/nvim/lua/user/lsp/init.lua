local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "user.lsp.lsp-installer"
require("user.lsp.handlers").setup()
require "user.lsp.null-ls"

-- clang language server
require "lspconfig".ccls.setup{
  init_options = {
    cache = {
      directory = ".ccls-cache";
    };
  }
}
-- python language server
require "lspconfig".pyright.setup{}
-- rust language server
require "lspconfig".rust_analyzer.setup{}
-- lua language server
require "lspconfig".sumneko_lua.setup{
  setting = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = '/usr/bin/luajit'
      }
    }
  }
}
-- markdown language server
require "lspconfig".marksman.setup{}
