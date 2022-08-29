--local profile_start_time = vim.loop.hrtime()

local treesitter = require("nvim-treesitter.configs")

-- constants for selection_modes
local charwise = "v"
local linewise = "V"
local blockwise = "<c-v>"

treesitter.setup {
    ensure_installed = "all",
    sync_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true,
        disable = { "yaml" },
    },
    matchup = {
        enable = true,
        disable = {},
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
            selection_modes = {
                ["@parameter.outer"] = charwise,
                ["@function.outer"] = linewise,
                ["@class.outer"] = linewise,
            },
        },
    },
}

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
