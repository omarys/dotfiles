return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        http = {
          opts = {
            show_model_choices = false,
          },
          -- OpenCode Go
          opencode_go = function()
            return require("codecompanion.adapters").extend("openai", {
              name = "opencode_go",
              formatted_name = "OpenCode Go",
              url = "https://opencode.ai/zen/go/v1/chat/completions",

              env = {
                api_key = "cmd:pass show opencode_go_key_code_companion",
              },

              schema = {
                model = {
                  default = "deepseek-v4-flash",
                },
              },
            })
          end,
        },

        acp = {
          -- OpenAI Codex
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "chat-gpt",
              },
            })
          end,
        },
      },

      interactions = {
        chat = {
          adapter = {
            name = "opencode_go",
            model = "deepseek-v4-flash",
          },
        },

        inline = {
          adapter = {
            name = "opencode_go",
            model = "deepseek-v4-flash",
          },
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    })
  end,
}
