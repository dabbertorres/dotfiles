local lualine = require("lualine")
local toggleterm_status = require("toggleterm_lualine")
local treesitter = require("nvim-treesitter")

lualine.setup {
    options = {
        icons_enabled = true,
        theme = "gruvbox",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "toggleterm" },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 200,
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            "branch",
            {
                "diff",
                colored = true,
                diff_color = {
                    added = 'DiffAdd',
                    modified = 'DiffChange',
                    removed = 'DiffDelete',
                },
            },
        },
        lualine_c = {
            {
                "filename",
                file_status = true,
                path = 1,
            },
        },
        lualine_x = {
            -- "MatchupStatusOffscreen",
            { function() return treesitter.statusline(90) end },
            "filetype",
        },
        lualine_y = { "encoding", "fileformat" },
        lualine_z = { "location", "diagnostics" },
    },
    -- inactive_sections = {
    --     lualine_a = {},
    --     lualine_b = {},
    --     lualine_c = {
    --         {
    --             "filename",
    --             path = 1,
    --         },
    --     },
    --     lualine_x = {"location"},
    --     lualine_y = {},
    --     lualine_z = {},
    -- },
    tabline = {
        -- options = {
        --     section_separators = { left = "|", right = "|" },
        -- },
        lualine_a = {
            {
                "buffers",
                symbols = {
                    modified = " ●",
                    alternate_file = "",
                    directory = "",
                },
            },
        },
        lualine_y = {
            { toggleterm_status,                id = 1 },
            { toggleterm_status,                id = 2 },
            { toggleterm_status,                id = 3 },
            { toggleterm_status,                id = 4 },
            { toggleterm_status,                id = 5 },
            { toggleterm_status,                id = 6 },
            { toggleterm_status,                id = 7 },
            { toggleterm_status,                id = 8 },
            { toggleterm_status,                id = 9 },
            { toggleterm_status,                id = 10 },
            { toggleterm_status.terminal_icon() },
        },
        lualine_z = { "tabs" },
    },
    extensions = {},
}
