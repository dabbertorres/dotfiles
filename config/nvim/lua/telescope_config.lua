--local profile_start_time = vim.loop.hrtime()

local actions = require("telescope.actions")
local telescope = require("telescope")
local builtin = require("telescope.builtin")

local util = require("util")

telescope.setup{
    defaults = {
        vimgrep_arguments = {
            "ag",
            "--nocolor",
            "--noheading",
            "--filename",
            "--numbers",
            "--column",
            "--smart-case",
        },
        mappings = {
            i = {
                ["<C-n>"] = false,
                ["<C-p>"] = false,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
            },
        },
    },
    extensions = {
        file_browser = {},
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {},
    },
}

telescope.load_extension("file_browser")
telescope.load_extension("fzf")
telescope.load_extension("ui-select")
--telescope.load_extension("dap")

local mappings_opts = {
    noremap = true,
    silent = true,
}

local file_browser_opts = {
    grouped = false,
    depth = 1,
    hidden = false,
}

vim.api.nvim_set_keymap("n", "mfb", "", util.copy_with(mappings_opts, {
    callback = function()
        telescope.extensions.file_browser.file_browser(file_browser_opts)
    end}))
vim.api.nvim_set_keymap("n", "mff", "", util.copy_with(mappings_opts, { callback = builtin.find_files }))
vim.api.nvim_set_keymap("n", "msl", "", util.copy_with(mappings_opts, { callback = builtin.live_grep }))
vim.api.nvim_set_keymap("n", "mss", "", util.copy_with(mappings_opts, { callback = builtin.grep_string }))
vim.api.nvim_set_keymap("n", "msb", "", util.copy_with(mappings_opts, { callback = builtin.buffers }))
vim.api.nvim_set_keymap("n", "msh", "", util.copy_with(mappings_opts, { callback = builtin.help_tags }))

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
