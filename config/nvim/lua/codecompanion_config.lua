local default_adapter = "anthropic"

require("codecompanion").setup {
    -- adapters = {
    --     opts = {
    --         show_defaults = false,
    --     },
    --     acp = {
    --         gemini_cli = function()
    --             return require("codecompanion.adapters").extend("gemini_cli", {
    --                 defaults = {
    --                     auth_method = "oauth-personal"
    --                 },
    --             })
    --         end,
    --     },
    --     http = {
    --         ollama = function()
    --             return require("codecompanion.adapters").extend("ollama", {
    --                 name = "my ollama",
    --                 env = {
    --                     url = "http://192.168.0.25:11434",
    --                 },
    --                 headers = {
    --                     ["Content-Type"] = "application/json",
    --                 },
    --                 parameters = {
    --                     sync = true,
    --                 },
    --                 schema = {
    --                     model = {
    --                         default = "qwen2.5-coder:7b",
    --                     },
    --                     num_ctx = {
    --                         default = 131072,
    --                     },
    --                 },
    --             })
    --         end,
    --         opts = {
    --             show_defaults = false,
    --             show_presets = false,
    --         },
    --     },
    -- },
    interactions = {
        background = {
            adapter = default_adapter,
        },
        chat = {
            adapter = default_adapter,
            provider = default_adapter,
            slash_commands = {
                ["fetch"] = {
                    opts = {
                        provider = "telescope",
                    },
                },
                ["file"] = {
                    opts = {
                        provider = "telescope",
                    },
                },
            },
            tools = {
                ["memory"] = {
                    opts = {
                        whitelist = {
                            { path = "~/Code/folx", as = "/workspace" },
                        },
                    },
                },
                opts = {
                    auto_submit_errors = true,
                    auto_submit_success = true,
                },
            },
            opts = {
                completion_provider = "cmp",
                prompt_decorator = function(message, adapter, context)
                    return string.format([[<prompt>%s</prompt>]], message)
                end,
            },
        },
        cli = {
            agent = "claude_code",
            agents = {
                claude_code = {
                    cmd = "claude",
                    args = {},
                    description = "Claude Code CLI",
                    provider = "terminal",
                },
            },
        },
        cmd = {
            adapter = default_adapter,
            provider = default_adapter,
        },
        inline = {
            adapter = default_adapter,
            provider = default_adapter,
            keymaps = {
                accept_change = {
                    modes = { n = "ga" },
                    description = "Accept the suggested change",
                },
                reject_change = {
                    modes = { n = "gr" },
                    description = "Reject the suggested change",
                    opts = { nowait = true },
                },
                stop = {
                    modes = { n = "q" },
                    index = 4,
                    callback = "keymaps.stop",
                    description = "Stop request",
                },
            },
        },
    },
    display = {
        action_palette = {
            provider = "telescope",
            opts = {
                show_preset_actions = true,
                show_preset_prompts = true,
            },
        },
        chat = {
            floating_window = {
                width = function() return vim.o.columns - 5 end,
                height = function() return vim.o.lines - 2 end,
                -- row = "center",
                -- col = "center",
                relative = "editor",
                opts = {
                    wrap = false,
                    number = false,
                    relativenumber = false,
                },
            },
            icons = {
                chat_context = "📎️",
            },
            fold_context = true,
        },
        inline = {
            layout = "vertical",
        },
    },
}

vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "v" }, "<leader>ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.cmd([[cab cc CodeCompanion]])
