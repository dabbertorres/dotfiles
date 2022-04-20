--local profile_start_time = vim.loop.hrtime()

local treesitter = require"nvim-treesitter.configs"

treesitter.setup {
    ensure_installed = "maintained",
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
        disable = { "python", "yaml" },
    },
    matchup = {
        enable = true,
        disable = {},
    },
}

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
