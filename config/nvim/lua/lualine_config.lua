require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = "gruvbox",
        component_separators = { left = "", right = ""},
        section_separators = { left = "", right = ""},
        disabled_filetypes = {},
        always_divide_middle = true,
    },
    sections = {
        lualine_a = {"mode"},
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
            {function() return vim.fn["nvim_treesitter#statusline"](90) end},
            "filetype",
        },
        lualine_y = {"encoding", "fileformat"},
        lualine_z = {"location", "diagnostics"},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                "filename",
                path = 1,
            },
        },
        lualine_x = {"location"},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {
        lualine_a = {"buffers"},
        lualine_z = {"tabs"},
    },
    extensions = {}
}
