local gruvbox = require("gruvbox")

gruvbox.setup {
    inverse = true,
    invert_selection = false,
    invert_signs = true,
    invert_tabline = false,
    -- invert_intend_guides = true,
    constrast = "soft",
    overrides = {
        Normal = { bg = "#1d2021" },
        String = { italic = false },
        Operator = { italic = false },
    },
    dim_inactive = true,
}

vim.cmd [[
    set termguicolors
    set background=dark
    colorscheme gruvbox
]]
